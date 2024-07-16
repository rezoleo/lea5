# frozen_string_literal: true

module Admin
  class DashboardController < ApplicationController
    def index
      authorize! :manage, :all
      @articles = Article.order(created_at: :desc)
      @subscription_offers = SubscriptionOffer.order(created_at: :desc)
      @payment_methods = PaymentMethod.order(created_at: :desc)
    end
  end
end
