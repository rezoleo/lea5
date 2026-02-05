# frozen_string_literal: true

module Admin
  class AccountingController < ApplicationController
    before_action :set_date_range
    before_action :init_query

    def index
      authorize! :manage, :all

      @kpis = @query.kpis
      @revenue_data = @query.revenue_by_date
      @payment_methods_data = @query.payment_methods
      @top_items_data = @query.top_items
      @customer_metrics = @query.customer_metrics
      @sales_by_seller = @query.sales_by_seller
      @recent_sales = recent_sales_list
    end

    def export_csv
      authorize! :manage, :all

      send_data generate_csv_data,
                filename: "rezoleo_accounting_export_#{@start_date.to_date}_#{@end_date.to_date}.csv",
                type: 'text/csv'
    end

    private

    def init_query
      @query = AccountingQuery.new(
        start_date: @start_date,
        end_date: @end_date
      )
    end

    def recent_sales_list
      Sale.where(created_at: @start_date..@end_date)
          .where.not(verified_at: nil)
          .includes(:client, :seller, :payment_method,
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
          total: sale.total_price
        }
      end
    end

    def set_date_range
      @period = params[:period] || 'current_month'

      @start_date, @end_date =
        case @period
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
          [
            params[:start_date].present? ? Time.zone.parse(params[:start_date]) : Time.zone.now.beginning_of_month,
            params[:end_date].present? ? Time.zone.parse(params[:end_date]) : Time.zone.now.end_of_month
          ]
        else
          [Time.zone.now.beginning_of_month, Time.zone.now.end_of_month]
        end
    end

    def generate_csv_data
      CSV.generate(headers: true) do |csv|
        csv << csv_headers

        sql_query = Rails.root.join('app/queries/csv_export_query.sql').read
        sanitized_query = ActiveRecord::Base.sanitize_sql_array([
          sql_query,
          { start_date: @start_date, end_date: @end_date }
        ])

        results = ActiveRecord::Base.connection.execute(sanitized_query)

        results.each do |row|
          csv << [
            row['date'].to_datetime.strftime('%Y-%m-%d %H:%M'),
            row['sale_id'],
            row['client'],
            row['seller'],
            row['payment_method'],
            row['item_type'],
            row['item_name'],
            row['quantity'],
            format_cents(row['unit_price_cents']),
            format_cents(row['line_total_cents']),
            format_cents(row['sale_total_cents'])
          ]
        end
      end
    end

    def csv_headers
      ['Date', 'Sale ID', 'Client', 'Seller', 'Payment Method',
       'Item Type', 'Item Name', 'Quantity', 'Unit Price', 'Line Total', 'Sale Total']
    end

    def format_cents(cents)
      format('%.2f', cents.to_i / 100.0)
    end
  end
end
