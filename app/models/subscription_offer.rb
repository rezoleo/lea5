# frozen_string_literal: true

class SubscriptionOffer < ApplicationRecord
  has_many :sale_subscription_offers, dependent: :restrict_with_exception
  has_many :sales, through: :sale_subscription_offers
  has_many :refund_subscription_offers, dependent: :restrict_with_exception
  has_many :refunds, through: :refund_subscription_offers
end
