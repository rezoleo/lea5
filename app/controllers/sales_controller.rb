# frozen_string_literal: true

class SalesController < ApplicationController
  before_action :owner, only: [:new, :create]

  def new
    @sale = @owner.sales_as_client.new
    @articles = Article.where(deleted_at: nil)
    @subscription_offers = SubscriptionOffer.where(deleted_at: nil)
    authorize! :new, @sale
  end

  def create
    authorize! :create, @sale
  end

  def owner
    @owner = User.find(params[:user_id])
  end
end
