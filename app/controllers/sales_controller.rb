# frozen_string_literal: true

class SalesController < ApplicationController
  before_action :owner, only: [:new, :create]

  def new
    @sale = @owner.sales_as_client.new
    @sale.articles_sales.new
    @articles = Article.where(deleted_at: nil)
    @subscription_offers = SubscriptionOffer.where(deleted_at: nil)
    authorize! :new, @sale
  end

  def create
    @sale = @owner.sales_as_client.new(sales_params)
    authorize! :create, @sale
    @sale.save!
  end

  def owner
    @owner = User.find(params[:user_id])
  end

  private

  def sales_params
    params.require(:sale).permit(articles_sales_attributes: [:article_id, :quantity])
  end
end
