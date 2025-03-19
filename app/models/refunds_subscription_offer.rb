# frozen_string_literal: true

class RefundsSubscriptionOffer < ApplicationRecord
  belongs_to :refund
  belongs_to :subscription_offer
end
