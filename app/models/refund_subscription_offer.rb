# frozen_string_literal: true

class RefundSubscriptionOffer < ApplicationRecord
  belongs_to :refund
  belongs_to :subscription_offer
end
