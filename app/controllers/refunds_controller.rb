# frozen_string_literal: true

class RefundsController < ApplicationController
  before_action :sale, only: [:new, :create]

  def new
    authorize! :create, Refund
    @refund = Refund.new(sale: @sale)
    load_form_data
  end

  def create
    authorize! :create, Refund
    @refund = Refund.create_with_credit_note(
      sale: @sale,
      refund_method: PaymentMethod.find_by(id: refund_params[:refund_method_id]),
      refunder: current_user,
      refund_scope: {
        article_ids: refund_params[:article_ids] || [],
        refund_subscription: ActiveModel::Type::Boolean.new.cast(refund_params[:refund_subscription])
      }
    )

    if @refund.persisted?
      flash[:success] = 'Refund created!'
      redirect_to @sale.client
    else
      load_form_data
      render 'new', status: :unprocessable_entity
    end
  end

  private

  def sale
    @sale = Sale.find(params[:sale_id])
  end

  def load_form_data
    @refundable_article_sales = @sale.refundable_article_sales.includes(:article)
    @subscription = @sale.subscription
    @refund_methods = PaymentMethod.all
  end

  def refund_params
    params.require(:refund).permit(:refund_method_id, :refund_subscription, article_ids: [])
  end
end
