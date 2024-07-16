# frozen_string_literal: true

class SalesController < ApplicationController
  before_action :owner, only: [:new, :create]

  def new
    @sale = @owner.sales_as_client.new
    @sale.articles_sales.new
    @articles = Article.all
    @subscription_offers = SubscriptionOffer.order(duration: :desc)
    @payment_methods = PaymentMethod.all
    authorize! :new, @sale
  end

  def create
    @sale = @owner.sales_as_client.new(sales_params)
    @sale.generate(duration: params[:sale][:duration], seller: current_user)
    redirect_to :new_user_sale, user: @user, status: :unprocessable_entity if @sale.empty
    authorize! :create, @sale
    if @sale.save
      flash[:success] = 'Sale was successfully created.'
      redirect_to @owner
    else
      redirect_to :new_user_sale, user: @user, status: :unprocessable_entity
    end
  end

  private

  def owner
    @owner = User.find(params[:user_id])
  end

  def sales_params
    params.require(:sale).permit(:payment_method_id, articles_sales_attributes: [:article_id, :quantity])
  end
end
