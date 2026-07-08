# frozen_string_literal: true

module Admin
  class AccountingController < ApplicationController
    before_action :set_date_range
    before_action :init_query

    def index
      authorize! :manage, :all

      @kpis = @query.kpis
      @revenue_data = @query.revenue_by_date
    end

    def export
      authorize! :manage, :all

      send_data generate_csv_data,
                filename: "rezoleo_export_#{@start_date.to_date}_#{@end_date.to_date}.csv",
                type: 'text/csv'
    end

    private

    def init_query
      @query = AccountingQuery.new(
        start_date: @start_date,
        end_date: @end_date
      )
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
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
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def generate_csv_data
      CSV.generate(headers: true) do |csv|
        csv << csv_headers

        sanitized_query = ActiveRecord::Base.sanitize_sql_array([
          Rails.root.join('app/queries/csv_export_query.sql').read,
          { start_date: @start_date, end_date: @end_date }
        ])

        results = ActiveRecord::Base.connection.execute(sanitized_query)

        results.each do |row|
          csv << [
            format_date(row['date']),
            row['invoice_number'],
            row['transaction_type'],
            row['transaction_id'],
            row['client'],
            row['seller'],
            row['payment_method'],
            row['item_type'],
            row['item_name'],
            row['quantity'].to_i,
            format_currency(row['unit_price_cents']),
            format_currency(row['line_total_cents'])
          ]
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    def csv_headers
      [
        'Date', 'Invoice Number', 'Transaction Type', 'Transaction ID',
        'Client', 'Seller', 'Payment Method', 'Item Type',
        'Item Name', 'Quantity', 'Unit Price', 'Line Total'
      ]
    end

    def format_date(date_value)
      date_value.in_time_zone&.strftime('%Y-%m-%d %H:%M:%S %Z')
    end

    def format_currency(cents)
      cents.to_i / 100.0
    end
  end
end
