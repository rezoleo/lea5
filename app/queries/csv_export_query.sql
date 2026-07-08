WITH sale_articles AS (
    SELECT s.created_at AS date
        , i.number AS invoice_number
        , 'Sale' AS transaction_type
        , s.id AS transaction_id
        , c.username AS client
        , COALESCE(sel.username, 'N/A') AS seller
        , pm.name AS payment_method
        , 'Article' AS item_type
        , a.name AS item_name
        , asu.quantity AS quantity
        , a.price_cents AS unit_price_cents
        , (asu.quantity * a.price_cents) AS line_total_cents

    FROM sales s
        JOIN invoices i ON i.id = s.invoice_id
        JOIN users c ON c.id = s.client_id
        LEFT JOIN users sel ON sel.id = s.seller_id
        JOIN payment_methods pm ON pm.id = s.payment_method_id
        JOIN articles_sales asu ON asu.sale_id = s.id
        JOIN articles a ON a.id = asu.article_id

    WHERE s.verified_at IS NOT NULL AND s.created_at BETWEEN :start_date AND :end_date
)

, sale_subs AS (
    SELECT s.created_at AS date
        , i.number AS invoice_number
        , 'Sale' AS transaction_type
        , s.id AS transaction_id
        , c.username AS client
        , COALESCE(sel.username, 'N/A') AS seller
        , pm.name AS payment_method
        , 'Subscription' AS item_type
        , CONCAT(so.duration, ' months') AS item_name
        , sso.quantity AS quantity
        , so.price_cents AS unit_price_cents
        , (sso.quantity * so.price_cents) AS line_total_cents

    FROM sales s
        JOIN invoices i ON i.id = s.invoice_id
        JOIN users c ON c.id = s.client_id
        LEFT JOIN users sel ON sel.id = s.seller_id
        JOIN payment_methods pm ON pm.id = s.payment_method_id
        JOIN sales_subscription_offers sso ON sso.sale_id = s.id
        JOIN subscription_offers so ON so.id = sso.subscription_offer_id

    WHERE s.verified_at IS NOT NULL AND s.created_at BETWEEN :start_date AND :end_date
),

refund_articles AS (
    SELECT r.created_at AS date
        , i.number AS invoice_number
        , 'Refund' AS transaction_type
        , r.id AS transaction_id
        , c.username AS client
        , COALESCE(ref.username, 'N/A') AS seller
        , rm.name AS payment_method
        , 'Article (Refund)' AS item_type
        , a.name AS item_name
        , -ar.quantity AS quantity
        , a.price_cents AS unit_price_cents
        , -(ar.quantity * a.price_cents) AS line_total_cents

    FROM refunds r
        JOIN invoices i ON i.id = r.invoice_id
        JOIN sales s ON s.id = r.sale_id
        JOIN users c ON c.id = s.client_id
        LEFT JOIN users ref ON ref.id = r.refunder_id
        JOIN payment_methods rm ON rm.id = r.refund_method_id
        JOIN articles_refunds ar ON ar.refund_id = r.id
        JOIN articles a ON a.id = ar.article_id

    WHERE r.created_at BETWEEN :start_date AND :end_date
),

refund_subs AS (
    SELECT r.created_at AS date
        , i.number AS invoice_number
        , 'Refund' AS transaction_type
        , r.id AS transaction_id
        , c.username AS client
        , COALESCE(ref.username, 'N/A') AS seller
        , rm.name AS payment_method
        , 'Subscription (Refund)' AS item_type
        , 'Prorated Subscription Refund' AS item_name
        , -1 AS quantity
        , r.subscription_refund_cents AS unit_price_cents
        , -r.subscription_refund_cents AS line_total_cents

    FROM refunds r
        JOIN invoices i ON i.id = r.invoice_id
        JOIN sales s ON s.id = r.sale_id
        JOIN users c ON c.id = s.client_id
        LEFT JOIN users ref ON ref.id = r.refunder_id
        JOIN payment_methods rm ON rm.id = r.refund_method_id

    WHERE r.subscription_refund_cents IS NOT NULL AND r.created_at BETWEEN :start_date AND :end_date
)

SELECT date
    , invoice_number
    , transaction_type
    , transaction_id
    , client
    , seller
    , payment_method
    , item_type
    , item_name
    , quantity
    , unit_price_cents
    , line_total_cents

FROM (
    SELECT * FROM sale_articles
    UNION ALL
    SELECT * FROM sale_subs
    UNION ALL
    SELECT * FROM refund_articles
    UNION ALL
    SELECT * FROM refund_subs
) AS all_lines

ORDER BY date, invoice_number;