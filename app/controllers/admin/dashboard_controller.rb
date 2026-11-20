# frozen_string_literal: true

module Admin
  class DashboardController < ApplicationController
    def index
      authorize! :manage, :all # TODO: use finer grained permissions
      @articles = Article.sellable.accessible_by(current_ability).order(created_at: :desc)
      @subscription_offers = SubscriptionOffer.sellable.accessible_by(current_ability).order(created_at: :desc)
      @payment_methods = PaymentMethod.sellable.accessible_by(current_ability).order(created_at: :desc)
    end
  end
end
