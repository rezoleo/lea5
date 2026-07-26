# frozen_string_literal: true

require 'test_helper'

class AccountingQueryTest < ActiveSupport::TestCase
  def setup
    super
    @start_date = Time.zone.local(2030, 1, 1)
    @end_date = Time.zone.local(2030, 1, 31, 23, 59, 59)
    @query = AccountingQuery.new(start_date: @start_date, end_date: @end_date)
  end

  test 'verified_sales only includes verified sales within the date range' do
    in_range_verified = create_sale(client: users(:pepper), created_at: Time.zone.local(2030, 1, 15))
    create_sale(client: users(:ironman), created_at: Time.zone.local(2030, 1, 15),
                payment_method: payment_methods(:bank_transfer))
    create_sale(client: users(:spiderman), created_at: Time.zone.local(2030, 2, 1))

    assert_equal [in_range_verified.id], @query.verified_sales.pluck(:id)
  end

  test 'kpis sums the revenue and counts only verified sales within the date range' do
    create_sale(client: users(:pepper), created_at: Time.zone.local(2030, 1, 15),
                article_line: { article: articles(:cable), quantity: 2 })
    create_sale(client: users(:ironman), created_at: Time.zone.local(2030, 1, 20),
                article_line: { article: articles(:adapter), quantity: 1 })
    # Excluded: not verified
    create_sale(client: users(:spiderman), created_at: Time.zone.local(2030, 1, 18),
                payment_method: payment_methods(:bank_transfer))
    # Excluded: outside the date range
    create_sale(client: users(:pepper), created_at: Time.zone.local(2030, 2, 5))

    kpis = @query.kpis

    assert_equal Money.new(400 + 1500), kpis[:total_revenue]
    assert_equal 2, kpis[:transaction_count]
  end

  test 'kpis sums subscription months sold for verified sales within the date range' do
    create_sale(client: users(:pepper), created_at: Time.zone.local(2030, 1, 10), duration: 1)
    create_sale(client: users(:ironman), created_at: Time.zone.local(2030, 1, 12), duration: 12)
    # Excluded: not verified
    create_sale(client: users(:spiderman), created_at: Time.zone.local(2030, 1, 14), duration: 1,
                payment_method: payment_methods(:bank_transfer))

    assert_equal 13, @query.kpis[:total_months_sold]
  end

  test 'kpis growth_rate compares revenue against the equally-sized previous period' do
    create_sale(client: users(:pepper), created_at: Time.zone.local(2030, 1, 15),
                article_line: { article: articles(:cable), quantity: 5 })
    create_sale(client: users(:ironman), created_at: Time.zone.local(2029, 12, 15),
                article_line: { article: articles(:cable), quantity: 1 })

    assert_in_delta(400.0, @query.kpis[:growth_rate])
  end

  test 'kpis growth_rate is zero when the previous period has no revenue' do
    create_sale(client: users(:pepper), created_at: Time.zone.local(2030, 1, 15))

    assert_equal 0, @query.kpis[:growth_rate]
  end

  test 'revenue_by_date buckets verified revenue per day and fills empty days with zero' do
    query = AccountingQuery.new(start_date: Time.zone.local(2030, 1, 1),
                                end_date: Time.zone.local(2030, 1, 3, 23, 59, 59))
    create_sale(client: users(:pepper), created_at: Time.zone.local(2030, 1, 1, 10),
                article_line: { article: articles(:cable), quantity: 1 })
    create_sale(client: users(:ironman), created_at: Time.zone.local(2030, 1, 1, 18),
                article_line: { article: articles(:cable), quantity: 1 })
    create_sale(client: users(:spiderman), created_at: Time.zone.local(2030, 1, 3),
                article_line: { article: articles(:adapter), quantity: 1 })

    data = query.revenue_by_date

    assert_in_delta(4.0, data[Date.new(2030, 1, 1)])
    assert_in_delta(0.0, data[Date.new(2030, 1, 2)])
    assert_in_delta(15.0, data[Date.new(2030, 1, 3)])
  end

  private

  def create_sale(client:, created_at:, payment_method: payment_methods(:cash), duration: 0, article_line: {})
    article = article_line.fetch(:article, articles(:cable))
    quantity = article_line.fetch(:quantity, 1)

    travel_to(created_at) do
      attributes = {
        client: client,
        duration: duration,
        payment_method: payment_method,
        articles_sales_attributes: duration.positive? ? [] : [{ article_id: article.id, quantity: quantity }]
      }
      sale = Sale.build_with_invoice(attributes, seller: client)
      sale.save!
      sale
    end
  end
end
