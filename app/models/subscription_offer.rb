# frozen_string_literal: true

class SubscriptionOffer < ApplicationRecord
  has_many :sales_subscription_offers, dependent: :restrict_with_exception
  has_many :sales, through: :sales_subscription_offers
  has_many :refunds_subscription_offers, dependent: :restrict_with_exception
  has_many :refunds, through: :refunds_subscription_offers
end
