# frozen_string_literal: true

class SalesSubscriptionOffer < ApplicationRecord
  belongs_to :sale
  belongs_to :subscription_offer

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
