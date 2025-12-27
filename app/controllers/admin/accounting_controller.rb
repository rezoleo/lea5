# frozen_string_literal: true

module Admin
  # rubocop:disable Metrics/ClassLength
  class AccountingController < ApplicationController
    before_action :set_date_range

    def index
      authorize! :manage, :all

      @kpis = calculate_kpis
      @revenue_data = revenue_by_date
      @payment_methods_data = payment_methods_breakdown
      @top_items_data = top_items_performance
      @recent_sales = recent_sales_list
      @customer_metrics = customer_metrics
      @sales_by_seller = sales_by_seller
    end

    def export_csv
      authorize! :manage, :all

      csv_data = generate_csv_data
      send_data csv_data,
                filename: "accounting_export_#{@start_date.to_date}_#{@end_date.to_date}.csv",
                type: 'text/csv'
    end

    private

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    def set_date_range
      @period = params[:period] || 'current_month'

      case @period
      when 'last_month'
        @start_date = 1.month.ago.beginning_of_month
        @end_date = 1.month.ago.end_of_month
      when 'last_30_days'
        @start_date = 30.days.ago.beginning_of_day
        @end_date = Time.zone.now.end_of_day
      when 'current_year'
        @start_date = Time.zone.now.beginning_of_year
        @end_date = Time.zone.now.end_of_year
      when 'last_year'
        @start_date = 1.year.ago.beginning_of_year
        @end_date = 1.year.ago.end_of_year
      when 'all_time'
        @start_date = Sale.minimum(:created_at) || Time.zone.now
        @end_date = Time.zone.now
      when 'custom'
        @start_date = params[:start_date].present? ? Time.zone.parse(params[:start_date]) : default_start_date
        @end_date = params[:end_date].present? ? Time.zone.parse(params[:end_date]) : default_end_date
      else
        @start_date = Time.zone.now.beginning_of_month
        @end_date = Time.zone.now.end_of_month
      end
    end

    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength

    def sales_scope
      Sale.where(created_at: @start_date..@end_date)
    end

    def verified_sales_scope
      sales_scope.where.not(verified_at: nil)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def calculate_kpis
      sales = verified_sales_scope.includes(:sales_subscription_offers, subscription_offers: [])

      total_revenue = sales.sum(Money.zero, &:total_price)
      transaction_count = sales.count
      avg_transaction = transaction_count.positive? ? total_revenue / transaction_count : Money.zero

      total_months_sold = 0
      subscription_revenue = Money.zero

      sales.each do |sale|
        sale.sales_subscription_offers.each do |sso|
          total_months_sold += sso.quantity * sso.subscription_offer.duration
          subscription_revenue += sso.subscription_offer.price * sso.quantity
        end
      end

      period_length = @end_date - @start_date
      previous_sales = Sale.where(created_at: (@start_date - period_length)..@start_date)
                           .where.not(verified_at: nil)
      previous_revenue = previous_sales.sum(Money.zero, &:total_price)

      growth_rate =
        if previous_revenue.positive?
          ((total_revenue - previous_revenue) / previous_revenue * 100).round(2)
        else
          0
        end

      avg_price_per_month =
        total_months_sold.positive? ? subscription_revenue / total_months_sold : Money.zero

      {
        total_revenue: total_revenue,
        transaction_count: transaction_count,
        avg_transaction_value: avg_transaction,
        growth_rate: growth_rate,
        total_months_sold: total_months_sold,
        avg_price_per_month: avg_price_per_month
      }
    end

    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    def revenue_by_date
      range = @start_date.to_date..@end_date.to_date
      data = range.index_with { 0.0 }

      verified_sales_scope.find_each do |sale|
        date = sale.created_at.to_date
        data[date] += sale.total_price.to_f if data.key?(date)
      end

      data
    end

    def payment_methods_breakdown
      breakdown = verified_sales_scope.includes(:payment_method).group_by(&:payment_method)
      results = breakdown.map do |payment_method, sales|
        amount = sales.sum(Money.zero, &:total_price)

        {
          name: payment_method.name,
          count: sales.size,
          amount: amount,
          amount_chart: amount.to_f,
          avg_value: sales.any? ? amount / sales.size : Money.zero,
          auto_verified: payment_method.auto_verify
        }
      end
      results.sort_by { |pm| -pm[:amount].cents }
    end

    def top_items_performance
      items = build_items_data
      total_revenue = items.values.sum { |i| i[:revenue].cents }

      results = items.values.map do |item|
        item[:percentage] = total_revenue.positive? ? (item[:revenue].cents.to_f / total_revenue * 100).round(2) : 0
        item
      end

      results.sort_by { |i| -i[:revenue].cents }.first(10)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def build_items_data
      items = {}

      # Add articles
      verified_sales_scope.includes(articles_sales: :article).find_each do |sale|
        sale.articles_sales.each do |as|
          article = as.article
          key = "article_#{article.id}"
          items[key] ||= {
            name: article.name,
            type: 'Article',
            quantity: 0,
            revenue: Money.zero
          }

          items[key][:quantity] += as.quantity
          items[key][:revenue] += article.price * as.quantity
        end
      end

      # Add subscription offers
      verified_sales_scope.includes(sales_subscription_offers: :subscription_offer).find_each do |sale|
        sale.sales_subscription_offers.each do |sso|
          offer = sso.subscription_offer
          key = "subscription_#{offer.id}"
          items[key] ||= {
            name: "#{offer.duration} mois",
            type: 'Subscription',
            quantity: 0,
            revenue: Money.zero
          }

          items[key][:quantity] += sso.quantity
          items[key][:revenue] += offer.price * sso.quantity
        end
      end

      items
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def recent_sales_list
      verified_sales_scope.includes(:client, :seller, :payment_method,
                                    :articles_sales, :sales_subscription_offers,
                                    articles: [], subscription_offers: [])
                          .order(created_at: :desc)
                          .limit(5)
                          .map do |sale|
        {
          id: sale.id,
          date: sale.created_at,
          client: sale.client.display_name,
          seller: sale.seller&.display_name || 'N/A',
          payment_method: sale.payment_method.name,
          total: sale.total_price,
          items_count: sale.articles_sales.count + sale.sales_subscription_offers.count
        }
      end
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def customer_metrics
      sales = verified_sales_scope.includes(:client)
      clients = sales.map(&:client).uniq

      new_customers = clients.count do |client|
        first_sale = client.sales.where.not(verified_at: nil).minimum(:created_at)
        first_sale && first_sale >= @start_date
      end

      customer_revenues = sales.group_by(&:client)
                               .transform_values { |s| s.sum(Money.zero, &:total_price) }

      avg_ltv =
        customer_revenues.any? ? customer_revenues.values.sum / customer_revenues.size : Money.zero

      {
        new_customers: new_customers,
        total_customers: clients.size,
        avg_lifetime_value: avg_ltv,
        top_customers: customer_revenues.sort_by { |_, r| -r.cents }.first(10).map do |customer, revenue|
          {
            name: customer.display_name,
            revenue: revenue,
            transaction_count: sales.count { |s| s.client == customer }
          }
        end
      }
    end

    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    def sales_by_seller
      seller_sales = verified_sales_scope.includes(:seller).select(&:seller).group_by(&:seller)
      results = seller_sales.map do |seller, sales|
        {
          name: seller.display_name,
          count: sales.size,
          revenue: sales.sum(Money.zero, &:total_price)
        }
      end
      results.sort_by { |s| -s[:revenue].cents }
    end

    def generate_csv_data
      CSV.generate(headers: true) do |csv|
        csv << csv_headers
        export_sales_to_csv(csv)
        export_refunds_to_csv(csv)
      end
    end

    def csv_headers
      ['Date', 'Sale ID', 'Client', 'Seller', 'Payment Method',
       'Item Type', 'Item Name', 'Quantity', 'Unit Price', 'Line Total', 'Sale Total']
    end

    def export_sales_to_csv(csv)
      sales_for_export.find_each do |sale|
        export_sale_articles(csv, sale)
        export_sale_subscriptions(csv, sale)
      end
    end

    def export_refunds_to_csv(csv)
      refunds_for_export.find_each do |refund|
        export_refund_articles(csv, refund)
        export_refund_subscriptions(csv, refund)
      end
    end

    def sales_for_export
      verified_sales_scope.includes(:articles_sales, :sales_subscription_offers,
                                    :client, :seller, :payment_method,
                                    articles: [], subscription_offers: [])
    end

    def refunds_for_export
      Refund.where(sale_id: sales_for_export.select(:id))
            .where(created_at: @start_date..@end_date)
            .includes(:articles_refunds, :refunds_subscription_offers,
                      :refunder, :refund_method, :sale,
                      articles: [], subscription_offers: [])
    end

    def export_sale_articles(csv, sale)
      sale.articles_sales.each do |as|
        csv << sale_row(sale, 'Article', as.article.name, as.quantity,
                        as.article.price, as.article.price * as.quantity)
      end
    end

    def export_sale_subscriptions(csv, sale)
      sale.sales_subscription_offers.each do |sso|
        name = "#{sso.subscription_offer.duration} months"
        csv << sale_row(sale, 'Subscription', name, sso.quantity,
                        sso.subscription_offer.price, sso.subscription_offer.price * sso.quantity)
      end
    end

    def export_refund_articles(csv, refund)
      refund.articles_refunds.each do |ar|
        csv << refund_row(refund, 'Article (Refund)', ar.article.name, -ar.quantity,
                          ar.article.price, -(ar.article.price * ar.quantity))
      end
    end

    def export_refund_subscriptions(csv, refund)
      refund.refunds_subscription_offers.each do |rso|
        name = "#{rso.subscription_offer.duration} months"
        csv << refund_row(refund, 'Subscription (Refund)', name, -rso.quantity,
                          rso.subscription_offer.price, -(rso.subscription_offer.price * rso.quantity))
      end
    end

    # rubocop:disable Metrics/ParameterLists
    def sale_row(sale, item_type, item_name, quantity, unit_price, line_total)
      [
        sale.created_at.strftime('%Y-%m-%d %H:%M'),
        sale.id,
        sale.client.display_name,
        sale.seller&.display_name || 'N/A',
        sale.payment_method.name,
        item_type,
        item_name,
        quantity,
        format_money(unit_price),
        format_money(line_total),
        format_money(sale.total_price)
      ]
    end

    # rubocop:enable Metrics/ParameterLists

    # rubocop:disable Metrics/ParameterLists
    def refund_row(refund, item_type, item_name, quantity, unit_price, line_total)
      [
        refund.created_at.strftime('%Y-%m-%d %H:%M'),
        refund.sale.id,
        refund.sale.client.display_name,
        refund.refunder&.display_name || 'N/A',
        refund.refund_method.name,
        item_type,
        item_name,
        quantity,
        format_money(unit_price),
        format_money(line_total),
        format_money(-refund.total_price)
      ]
    end

    # rubocop:enable Metrics/ParameterLists

    def format_money(money)
      format('%.2f', money.cents / 100.0)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    def date_range_for_period(period)
      case period
      when 'last_month'
        [1.month.ago.beginning_of_month, 1.month.ago.end_of_month]
      when 'last_30_days'
        [30.days.ago.beginning_of_day, Time.zone.now.end_of_day]
      when 'current_year'
        [Time.zone.now.beginning_of_year, Time.zone.now.end_of_year]
      when 'last_year'
        [1.year.ago.beginning_of_year, 1.year.ago.end_of_year]
      when 'all_time'
        [Sale.minimum(:created_at) || Time.zone.now, Time.zone.now]
      when 'custom'
        custom_date_range
      else
        [Time.zone.now.beginning_of_month, Time.zone.now.end_of_month]
      end
    end

    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

    def custom_date_range
      start_date = params[:start_date].present? ? Time.zone.parse(params[:start_date]) : default_start_date
      end_date = params[:end_date].present? ? Time.zone.parse(params[:end_date]) : default_end_date
      [start_date, end_date]
    end

    def default_start_date
      Time.zone.now.beginning_of_month
    end

    def default_end_date
      Time.zone.now.end_of_month
    end
  end

  # rubocop:enable Metrics/ClassLength
end
