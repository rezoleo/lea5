# frozen_string_literal: true

module Admin
  class DashboardController < ApplicationController
    def index
      authorize! :manage, :all
      @articles = Article.where(deleted_at: nil).order(created_at: :desc)
      @subscription_offers = SubscriptionOffer.where(deleted_at: nil).order(created_at: :desc)
      @payment_methods = PaymentMethod.where(deleted_at: nil).order(created_at: :desc)
    end
  end
end
