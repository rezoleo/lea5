WITH
-- Sale lines (articles + subscriptions). Sale totals come from the stored
-- sales.total_cents snapshot.
sale_lines AS (SELECT s.created_at                   AS date,
                      s.id                           AS sale_id,
                      c.username                     AS client,
                      COALESCE(sel.username, 'N/A')  AS seller,
                      pm.name                        AS payment_method,
                      'Article'                      AS item_type,
                      a.name                         AS item_name,
                      asu.quantity                   AS quantity,
                      a.price_cents                  AS unit_price_cents,
                      (asu.quantity * a.price_cents) AS line_total_cents,
                      s.total_cents                  AS sale_total_cents
               FROM sales s
                        JOIN users c ON c.id = s.client_id
                        LEFT JOIN users sel ON sel.id = s.seller_id
                        JOIN payment_methods pm ON pm.id = s.payment_method_id
                        JOIN articles_sales asu ON asu.sale_id = s.id
                        JOIN articles a ON a.id = asu.article_id
               WHERE s.verified_at IS NOT NULL
                 AND s.created_at BETWEEN :start_date AND :end_date

               UNION ALL

               SELECT s.created_at,
                      s.id,
                      c.username,
                      COALESCE(sel.username, 'N/A'),
                      pm.name,
                      'Subscription',
                      CONCAT(so.duration, ' months'),
                      sso.quantity,
                      so.price_cents,
                      (sso.quantity * so.price_cents),
                      s.total_cents
               FROM sales s
                        JOIN users c ON c.id = s.client_id
                        LEFT JOIN users sel ON sel.id = s.seller_id
                        JOIN payment_methods pm ON pm.id = s.payment_method_id
                        JOIN sales_subscription_offers sso ON sso.sale_id = s.id
                        JOIN subscription_offers so ON so.id = sso.subscription_offer_id
               WHERE s.verified_at IS NOT NULL
                 AND s.created_at BETWEEN :start_date AND :end_date),

-- Refund totals (articles + subscriptions)
refund_totals AS (SELECT r.id                                          AS refund_id,
                         COALESCE(a.total, 0) + COALESCE(sub.total, 0) AS refund_total_cents
                  FROM refunds r
                           LEFT JOIN (SELECT ar.refund_id,
                                             SUM(ar.quantity * a.price_cents) AS total
                                      FROM articles_refunds ar
                                               JOIN articles a ON a.id = ar.article_id
                                      GROUP BY ar.refund_id) a ON a.refund_id = r.id
                           LEFT JOIN (SELECT rso.refund_id,
                                             SUM(rso.quantity * so.price_cents) AS total
                                      FROM refunds_subscription_offers rso
                                               JOIN subscription_offers so ON so.id = rso.subscription_offer_id
                                      GROUP BY rso.refund_id) sub ON sub.refund_id = r.id),

-- Refund lines (articles + subscriptions)
refund_lines AS (SELECT r.created_at                   AS date,
                        s.id                           AS sale_id,
                        c.username                     AS client,
                        COALESCE(ref.username, 'N/A')  AS seller,
                        rm.name                        AS payment_method,
                        'Article (Refund)'             AS item_type,
                        a.name                         AS item_name,
                        -ar.quantity                   AS quantity,
                        a.price_cents                  AS unit_price_cents,
                        -(ar.quantity * a.price_cents) AS line_total_cents,
                        -rt.refund_total_cents         AS sale_total_cents
                 FROM refunds r
                          JOIN refund_totals rt ON rt.refund_id = r.id
                          JOIN sales s ON s.id = r.sale_id
                          JOIN users c ON c.id = s.client_id
                          LEFT JOIN users ref ON ref.id = r.refunder_id
                          JOIN payment_methods rm ON rm.id = r.refund_method_id
                          JOIN articles_refunds ar ON ar.refund_id = r.id
                          JOIN articles a ON a.id = ar.article_id
                 WHERE r.created_at BETWEEN :start_date AND :end_date

                 UNION ALL

                 SELECT r.created_at,
                        s.id,
                        c.username,
                        COALESCE(ref.username, 'N/A'),
                        rm.name,
                        'Subscription (Refund)',
                        CONCAT(so.duration, ' months'),
                        -rso.quantity,
                        so.price_cents,
                        -(rso.quantity * so.price_cents),
                        -rt.refund_total_cents
                 FROM refunds r
                          JOIN refund_totals rt ON rt.refund_id = r.id
                          JOIN sales s ON s.id = r.sale_id
                          JOIN users c ON c.id = s.client_id
                          LEFT JOIN users ref ON ref.id = r.refunder_id
                          JOIN payment_methods rm ON rm.id = r.refund_method_id
                          JOIN refunds_subscription_offers rso ON rso.refund_id = r.id
                          JOIN subscription_offers so ON so.id = rso.subscription_offer_id
                 WHERE r.created_at BETWEEN :start_date AND :end_date)

-- Final selection: combine sale lines and refund lines
SELECT date,
       sale_id,
       client,
       seller,
       payment_method,
       item_type,
       item_name,
       quantity,
       unit_price_cents,
       line_total_cents,
       sale_total_cents
FROM (SELECT *
      FROM sale_lines
      UNION ALL
      SELECT *
      FROM refund_lines) all_lines
ORDER BY date, sale_id;
