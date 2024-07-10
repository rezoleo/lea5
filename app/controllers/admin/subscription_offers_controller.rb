# frozen_string_literal: true

module Admin
  class SubscriptionOffersController < ApplicationController
    def new
      @subscription_offer = SubscriptionOffer.new
      authorize! :new, @subscription_offer
    end

    def create
      @subscription_offer = SubscriptionOffer.new(subscription_offer_params)
      authorize! :create, @subscription_offer
      if @subscription_offer.save
        flash[:success] = "Subscription offer for #{subscription_offer_params[:duration]} months created!"
        redirect_to admin_path
      else
        render 'new', status: :unprocessable_entity
      end
    end

    def destroy
      @subscription_offer = SubscriptionOffer.find(params[:id])
      authorize! :destroy, @subscription_offer
      @subscription_offer.soft_delete unless @subscription_offer.destroy
      redirect_to admin_path
    end

    def subscription_offer_params
      params.require(:subscription_offer).permit(:price, :duration)
    end
  end
end
