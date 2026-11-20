# frozen_string_literal: true

class SalesController < ApplicationController
  before_action :owner, only: [:new, :create]

  def new
    @sale = @owner.sales_as_client.new
    authorize! :new, @sale

    @articles = Article.sellable
    @subscription_offers = SubscriptionOffer.sellable.order(duration: :desc)
    @payment_methods = PaymentMethod.sellable
  end

  def create
    @sale = @owner.sales_as_client.build_with_invoice(sales_params, seller: current_user)

    authorize! :create, @sale
    if @sale.save
      flash[:success] = 'Sale was successfully created.'
      redirect_to @owner
    else
      @articles = Article.sellable
      @subscription_offers = SubscriptionOffer.sellable.order(duration: :desc)
      @payment_methods = PaymentMethod.sellable

      render 'new', status: :unprocessable_entity
    end
  end

  private

  def owner
    @owner = User.find_by!(username: params[:user_username])
  end

  def sales_params
    params.expect(sale: [:duration, :payment_method_id, { articles_sales_attributes: [[:article_id, :quantity]] }])
  end
end
