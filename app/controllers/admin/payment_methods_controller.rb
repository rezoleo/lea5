# frozen_string_literal: true

module Admin
  # Do NOT implement edit/update methods, we want to keep
  # payment methods immutable.
  # If you want to edit a payment method, create a new one and
  # soft-delete the other.
  class PaymentMethodsController < ApplicationController
    def new
      @payment_method = PaymentMethod.new
      authorize! :new, @payment_method
    end

    def create
      @payment_method = PaymentMethod.new(payment_method_params)
      authorize! :create, @payment_method
      if @payment_method.save
        flash[:success] = "Payment method #{payment_method_params[:name]} created!"
        redirect_to admin_path
      else
        render 'new', status: :unprocessable_entity
      end
    end

    def destroy
      @payment_method = PaymentMethod.find(params[:id])
      authorize! :destroy, @payment_method
      # Try to destroy (if there is no associated sale/refund),
      # else soft-delete to keep current sales immutable (not
      # change payment method on past sales)
      @payment_method.destroy or @payment_method.soft_delete
      redirect_to admin_path
    end

    def payment_method_params
      params.require(:payment_method).permit(:name, :auto_verify)
    end
  end
end
