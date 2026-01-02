# frozen_string_literal: true

class AccountingQuery
  def initialize(start_date:, end_date:)
    @start_date = start_date
    @end_date = end_date
  end

  def verified_sales
    Sale
      .where(created_at: @start_date..@end_date)
      .where.not(verified_at: nil)
  end

  def kpis
    total_revenue_cents = verified_sales
                          .joins(articles_total_join)
                          .joins(subscriptions_total_join)
                          .sum('COALESCE(articles_totals.total,0) + COALESCE(subscriptions_totals.total,0)')

    transaction_count = verified_sales.count

    avg_transaction = transaction_count.positive? ? total_revenue_cents / transaction_count : 0

    subscription_stats = subscription_stats_sql
    previous_revenue_cents = previous_period_revenue

    growth_rate =
      if previous_revenue_cents.positive?
        ((total_revenue_cents - previous_revenue_cents).to_f / previous_revenue_cents * 100).round(2)
      else
        0
      end

    avg_price_per_month =
      subscription_stats[:months].positive? ? subscription_stats[:revenue] / subscription_stats[:months] : 0

    {
      total_revenue: Money.new(total_revenue_cents),
      transaction_count: transaction_count,
      avg_transaction_value: Money.new(avg_transaction),
      growth_rate: growth_rate,
      total_months_sold: subscription_stats[:months],
      avg_price_per_month: Money.new(avg_price_per_month)
    }
  end

  def revenue_by_date
    raw = verified_sales
          .joins(articles_total_join)
          .joins(subscriptions_total_join)
          .group('DATE(sales.created_at)')
          .sum('COALESCE(articles_totals.total,0) + COALESCE(subscriptions_totals.total,0)')

    (@start_date.to_date..@end_date.to_date).index_with do |date|
      raw[date] ? raw[date] / 100.0 : 0.0
    end
  end

  def payment_methods
    verified_sales
      .joins(:payment_method)
      .joins(articles_total_join)
      .joins(subscriptions_total_join)
      .group('payment_methods.id', 'payment_methods.name', 'payment_methods.auto_verify')
      .select(
        'payment_methods.name AS name',
        'payment_methods.auto_verify AS auto_verified',
        'COUNT(sales.id) AS count',
        'SUM(COALESCE(articles_totals.total,0) + COALESCE(subscriptions_totals.total,0)) AS amount'
      )
      .order('amount DESC')
      .map do |r|
      {
        name: r.name,
        count: r.count.to_i,
        amount: Money.new(r.amount),
        amount_chart: r.amount.to_f / 100.0,
        avg_value: r.count.to_i.positive? ? Money.new(r.amount) / r.count.to_i : Money.zero,
        auto_verified: r.auto_verified
      }
    end
  end

  def top_items
    items = article_items.merge(subscription_items) do |_k, a, b|
      {
        name: a[:name],
        type: a[:type],
        quantity: a[:quantity] + b[:quantity],
        revenue: a[:revenue] + b[:revenue]
      }
    end

    total_revenue = items.values.sum { |i| i[:revenue].cents }

    items.values
         .map do |i|
      i[:percentage] =
        total_revenue.positive? ? (i[:revenue].cents.to_f / total_revenue * 100).round(2) : 0
      i
    end
         .sort_by { |i| -i[:revenue].cents }
         .first(10)
  end

  def customer_metrics
    total_customers = verified_sales.select(:client_id).distinct.count

    new_customers = User
                    .joins(:sales)
                    .where.not(sales: { verified_at: nil })
                    .group('users.id')
                    .having('MIN(sales.created_at) >= ?', @start_date)
                    .count
                    .size

    revenues = verified_sales
               .joins(articles_total_join)
               .joins(subscriptions_total_join)
               .group(:client_id)
               .sum('COALESCE(articles_totals.total,0) + COALESCE(subscriptions_totals.total,0)')

    avg_ltv = revenues.any? ? Money.new(revenues.values.sum / revenues.size) : Money.zero

    top_customers = revenues
                    .sort_by { |_client_id, total| -total }
                    .first(10)
                    .map do |client_id, total|
      client = User.find(client_id)
      {
        name: client.display_name,
        revenue: Money.new(total),
        transaction_count: verified_sales.where(client_id: client_id).count
      }
    end

    {
      new_customers: new_customers,
      total_customers: total_customers,
      avg_lifetime_value: avg_ltv,
      top_customers: top_customers
    }
  end

  def sales_by_seller
    verified_sales
      .joins(:seller)
      .joins(articles_total_join)
      .joins(subscriptions_total_join)
      .group(:seller_id)
      .select(
        'sales.seller_id AS seller_id',
        'COUNT(sales.id) AS count',
        'SUM(COALESCE(articles_totals.total,0) + COALESCE(subscriptions_totals.total,0)) AS revenue'
      )
      .order('revenue DESC')
      .first(8)
      .map do |r|
      user = User.find(r.seller_id)
      {
        name: user.display_name,
        count: r.count.to_i,
        revenue: Money.new(r.revenue)
      }
    end
  end

  private

  def articles_total_join
    <<~SQL.squish
      LEFT JOIN (
        SELECT
          articles_sales.sale_id,
          SUM(articles.price_cents * articles_sales.quantity) AS total
        FROM articles_sales
        JOIN articles ON articles.id = articles_sales.article_id
        GROUP BY articles_sales.sale_id
      ) articles_totals ON articles_totals.sale_id = sales.id
    SQL
  end

  def subscriptions_total_join
    <<~SQL.squish
      LEFT JOIN (
        SELECT
          sales_subscription_offers.sale_id,
          SUM(subscription_offers.price_cents * sales_subscription_offers.quantity) AS total
        FROM sales_subscription_offers
        JOIN subscription_offers
          ON subscription_offers.id = sales_subscription_offers.subscription_offer_id
        GROUP BY sales_subscription_offers.sale_id
      ) subscriptions_totals ON subscriptions_totals.sale_id = sales.id
    SQL
  end

  def subscription_stats_sql
    row = SalesSubscriptionOffer
          .joins(:sale, :subscription_offer)
          .where(sales: { created_at: @start_date..@end_date })
          .where.not(sales: { verified_at: nil })
          .select(
            'SUM(sales_subscription_offers.quantity * subscription_offers.duration) AS months',
            'SUM(sales_subscription_offers.quantity * subscription_offers.price_cents) AS revenue'
          )
          .take

    {
      months: row&.months.to_i,
      revenue: row&.revenue.to_i
    }
  end

  def previous_period_revenue
    period_length = @end_date - @start_date

    Sale
      .where(created_at: (@start_date - period_length)...@start_date)
      .where.not(verified_at: nil)
      .joins(articles_total_join)
      .joins(subscriptions_total_join)
      .sum('COALESCE(articles_totals.total,0) + COALESCE(subscriptions_totals.total,0)')
  end

  def article_items
    Article
      .joins(articles_sales: :sale)
      .where(sales: { created_at: @start_date..@end_date })
      .where.not(sales: { verified_at: nil })
      .group('articles.id', 'articles.name')
      .select(
        'articles.id',
        'articles.name AS name',
        'SUM(articles_sales.quantity) AS quantity',
        'SUM(articles_sales.quantity * articles.price_cents) AS revenue'
      )
      .each_with_object({}) do |r, h|
      h["article_#{r.id}"] = {
        name: r.name,
        type: 'Article',
        quantity: r.quantity.to_i,
        revenue: Money.new(r.revenue)
      }
    end
  end

  def subscription_items
    SubscriptionOffer
      .joins(sales_subscription_offers: :sale)
      .where(sales: { created_at: @start_date..@end_date })
      .where.not(sales: { verified_at: nil })
      .group('subscription_offers.id', 'subscription_offers.duration')
      .select(
        'subscription_offers.id',
        'subscription_offers.duration AS duration',
        'SUM(sales_subscription_offers.quantity) AS quantity',
        'SUM(sales_subscription_offers.quantity * subscription_offers.price_cents) AS revenue'
      )
      .each_with_object({}) do |r, h|
      h["subscription_#{r.id}"] = {
        name: "#{r.duration} mois",
        type: 'Subscription',
        quantity: r.quantity.to_i,
        revenue: Money.new(r.revenue)
      }
    end
  end
end
