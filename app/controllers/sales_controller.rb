# frozen_string_literal: true

class SalesController < ApplicationController
  before_action :owner, only: [:new, :create]

  def new
    @sale = @owner.sales_as_client.new
    @articles = Article.all
    @subscription_offers = SubscriptionOffer.order(duration: :desc)
    @payment_methods = PaymentMethod.all
    authorize! :new, @sale
  end

  def create
    @sale = @owner.sales_as_client.build_with_invoice(sales_params, seller: current_user)

    authorize! :create, @sale
    if @sale.save
      flash[:success] = 'Sale was successfully created.'
      redirect_to @owner
    else
      @articles = Article.all
      @subscription_offers = SubscriptionOffer.order(duration: :desc)
      @payment_methods = PaymentMethod.all

      render 'new', status: :unprocessable_entity
    end
  end

  private

  def owner
    @owner = User.find(params[:user_id])
  end

  def sales_params
    params.require(:sale).permit(:duration, :payment_method_id, articles_sales_attributes: [:article_id, :quantity])
  end
end
