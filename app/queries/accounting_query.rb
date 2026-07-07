# frozen_string_literal: true

# Lightweight figures for the in-app accounting "glance" page: a few headline
# KPIs and a revenue-over-time series. Reads the stored `sales.total_cents`
# snapshot, so no per-sale total is recomputed here.
#
# Deep / exploratory analytics (payment methods, top items, customer LTV, seller
# breakdowns, line-item & refund exports) deliberately do NOT live here — they
# are built as Metabase questions. See docs/accounting-bi.md.
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
    total_revenue_cents = verified_sales.sum(:total_cents)

    {
      total_revenue: Money.new(total_revenue_cents),
      transaction_count: verified_sales.count,
      total_months_sold: subscription_months_sold,
      growth_rate: growth_rate(total_revenue_cents)
    }
  end

  def revenue_by_date
    raw = verified_sales
          .group('DATE(sales.created_at)')
          .sum(:total_cents)

    (@start_date.to_date..@end_date.to_date).index_with do |date|
      raw[date] ? raw[date] / 100.0 : 0.0
    end
  end

  private

  def growth_rate(total_revenue_cents)
    previous = previous_period_revenue
    return 0 unless previous.positive?

    ((total_revenue_cents - previous).to_f / previous * 100).round(2)
  end

  def subscription_months_sold
    SalesSubscriptionOffer
      .joins(:sale, :subscription_offer)
      .where(sales: { created_at: @start_date..@end_date })
      .where.not(sales: { verified_at: nil })
      .sum('sales_subscription_offers.quantity * subscription_offers.duration')
  end

  def previous_period_revenue
    period_length = @end_date - @start_date

    Sale
      .where(created_at: (@start_date - period_length)...@start_date)
      .where.not(verified_at: nil)
      .sum(:total_cents)
  end
end
