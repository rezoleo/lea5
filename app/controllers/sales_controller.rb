# frozen_string_literal: true

class SalesController < ApplicationController
  before_action :owner, only: [:new, :create]

  def new
    @sale = @owner.sales_as_client.new
    @sale.articles_sales.new
    @articles = Article.where(deleted_at: nil)
    @subscription_offers = SubscriptionOffer.where(deleted_at: nil).order(duration: :desc)
    @payment_methods = PaymentMethod.where(deleted_at: nil)
    authorize! :new, @sale
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @sale = @owner.sales_as_client.new(reformated_params)
    @sale.update_total_price
    @sale.seller = current_user
    if @sale.total_price.zero?
      flash.now[:error] = "You can't process an empty sale!"
      return render :new, status: :unprocessable_entity
    end
    @sale.verify if @sale.payment_method.auto_verify
    @sale.gen_temp_invoice
    authorize! :create, @sale
    if @sale.save
      name = @sale.generate_invoice_id
      @sale.invoice.pdf.attach(io: @sale.invoice.generate, filename: name, content_type: 'application/pdf')
      @sale.save!
      flash[:success] = 'Sale was successfully created.'
      redirect_to @owner
    else
      render :new, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def owner
    @owner = User.find(params[:user_id])
  end

  def sales_params
    params.require(:sale).permit(:duration, :payment_method_id, articles_sales_attributes: [:article_id, :quantity])
  end

  def reformated_params
    par = sales_params
    par[:sales_subscription_offers_attributes] = duration_to_subscription_offers sales_params[:duration].to_i
    par.delete(:duration)
    par[:articles_sales_attributes]&.each do |rec|
      par[:articles_sales_attributes].delete(rec[0]) if rec[1][:quantity].to_i.zero?
    end
    par
  end

  def duration_to_subscription_offers(duration)
    tab = []
    subscription_offers = SubscriptionOffer.where(deleted_at: nil).order(duration: :desc)
    if subscription_offers.empty?
      flash[:error] = 'There are no subscription offers registered!'
      return false
    end
    subscription_offers.each do |offer|
      break if duration.zero?

      quantity = duration / offer.duration
      if quantity.positive?
        tab << { subscription_offer_id: offer.id, quantity: quantity }
        duration -= quantity * offer.duration
      end
    end
    unless duration.zero?
      flash[:error] = 'Subscription offers are not exhaustive!'
      return false
    end
    tab
  end
end
