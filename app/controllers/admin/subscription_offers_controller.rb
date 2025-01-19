# frozen_string_literal: true

module Admin
  # Do NOT implement edit/update methods, we want to keep
  # subscription offers immutable.
  # If you want to edit a subscription offer, create a new one and
  # soft-delete the other.
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
      # Try to destroy (if there is no associated sale/refund),
      # else soft-delete to keep current sales immutable (not
      # change subscriptions on past sales)
      @subscription_offer.destroy or @subscription_offer.soft_delete
      redirect_to admin_path
    end

    def subscription_offer_params
      params.require(:subscription_offer).permit(:price, :duration)
    end
  end
end
