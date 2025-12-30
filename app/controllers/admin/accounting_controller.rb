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
          .includes(:client, :seller, :payment_method)
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
  end
end
