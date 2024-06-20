# frozen_string_literal: true

class SaleSubscriptionDetail < ApplicationRecord
  belongs_to :sale
  belongs_to :subscription_offer
end
