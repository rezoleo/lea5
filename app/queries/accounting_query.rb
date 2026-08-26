# frozen_string_literal: true

# Lightweight figures for the in-app accounting page.
class AccountingQuery
  DAY_BUCKET_MAX_SPAN = 62
  WEEK_BUCKET_MAX_SPAN = 731

  def initialize(start_date:, end_date:)
    @start_date = start_date
    @end_date = end_date
  end

  def verified_sales
    verified_sales_between(@start_date..@end_date)
  end

  def refunds_on_verified_sales
    refunds_between(@start_date..@end_date)
  end

  def kpis
    revenue_cents = net_revenue_cents(@start_date..@end_date)

    {
      total_revenue: Money.new(revenue_cents),
      transaction_count: verified_sales.count,
      total_months_sold: subscription_months_sold,
      growth_rate: growth_rate(revenue_cents)
    }
  end

  def revenue_by_date
    sales = verified_sales.group(bucket_expression('sales.created_at')).sum(:amount_cents)
    refunds = refunds_on_verified_sales.group(bucket_expression('refunds.created_at')).sum(:amount_cents)

    buckets.index_with do |bucket|
      (sales.fetch(bucket, 0) - refunds.fetch(bucket, 0)) / 100.0
    end
  end

  private

  def verified_sales_between(range)
    Sale
      .where(created_at: range)
      .where.not(verified_at: nil)
  end

  def refunds_between(range)
    Refund
      .joins(:sale)
      .where(created_at: range)
      .where.not(sales: { verified_at: nil })
  end

  def net_revenue_cents(range)
    verified_sales_between(range).sum(:amount_cents) - refunds_between(range).sum(:amount_cents)
  end

  # @return [Float, nil] nil when there is nothing comparable to measure against
  def growth_rate(revenue_cents)
    previous = previous_year_revenue
    return nil if previous.nil? || !previous.positive?

    ((revenue_cents - previous).to_f / previous * 100).round(2)
  end

  def subscription_months_sold
    SalesSubscriptionOffer
      .joins(:sale, :subscription_offer)
      .where(sales: { created_at: @start_date..@end_date })
      .where.not(sales: { verified_at: nil })
      .sum('sales_subscription_offers.quantity * subscription_offers.duration')
  end

  # @return [Integer, nil] nil when there is no comparable window
  def previous_year_revenue
    return nil if @end_date - 1.year > @start_date

    net_revenue_cents((@start_date - 1.year)..(@end_date - 1.year))
  end

  def granularity
    @granularity ||=
      case (@end_date.to_date - @start_date.to_date).to_i
      when 0..DAY_BUCKET_MAX_SPAN then :day
      when 0..WEEK_BUCKET_MAX_SPAN then :week
      else :month
      end
  end

  def bucket_expression(column)
    return "DATE(#{column})" if granularity == :day

    "DATE_TRUNC('#{granularity}', #{column})::date"
  end

  def buckets
    step = { day: 1.day, week: 1.week, month: 1.month }.fetch(granularity)
    last = @end_date.to_date

    Enumerator.produce(bucket_start(@start_date.to_date)) { |date| date + step }
              .take_while { |date| date <= last }
  end

  def bucket_start(date)
    case granularity
    when :week then date.beginning_of_week
    when :month then date.beginning_of_month
    else date
    end
  end
end
