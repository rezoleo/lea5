# frozen_string_literal: true

module Admin
  class DashboardController < ApplicationController
    def index
      authorize! :manage, :all # TODO: use finer grained permissions
      @articles = Article.accessible_by(current_ability).order(created_at: :desc)
      @subscription_offers = SubscriptionOffer.accessible_by(current_ability).order(created_at: :desc)
      @payment_methods = PaymentMethod.accessible_by(current_ability).order(created_at: :desc)
    end
  end
end
