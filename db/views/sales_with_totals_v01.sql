SELECT
  sales.id,
  sales.created_at,
  sales.updated_at,
  sales.verified_at,
  sales.client_id,
  sales.seller_id,
  sales.payment_method_id,
  COALESCE(articles_totals.total, 0) AS articles_total_cents,
  COALESCE(subscriptions_totals.total, 0) AS subscriptions_total_cents,
  COALESCE(articles_totals.total, 0) + COALESCE(subscriptions_totals.total, 0) AS total_cents
FROM sales
LEFT JOIN (
  SELECT
    articles_sales.sale_id,
    SUM(articles.price_cents * articles_sales.quantity) AS total
  FROM articles_sales
  JOIN articles ON articles.id = articles_sales.article_id
  GROUP BY articles_sales.sale_id
) articles_totals ON articles_totals.sale_id = sales.id
LEFT JOIN (
  SELECT
    sales_subscription_offers.sale_id,
    SUM(subscription_offers.price_cents * sales_subscription_offers.quantity) AS total
  FROM sales_subscription_offers
  JOIN subscription_offers ON subscription_offers.id = sales_subscription_offers.subscription_offer_id
  GROUP BY sales_subscription_offers.sale_id
) subscriptions_totals ON subscriptions_totals.sale_id = sales.id
