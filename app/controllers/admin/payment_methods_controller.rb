# frozen_string_literal: true

module Admin
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
      @payment_method.soft_delete unless @payment_method.destroy
      redirect_to admin_path
    end

    def payment_method_params
      params.require(:payment_method).permit(:name, :auto_verify)
    end
  end
end