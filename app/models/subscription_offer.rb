# frozen_string_literal: true

class SubscriptionOffer < ApplicationRecord
  has_many :sales_subscription_offers, dependent: :restrict_with_error
  has_many :sales, through: :sales_subscription_offers
  has_many :refunds_subscription_offers, dependent: :restrict_with_error
  has_many :refunds, through: :refunds_subscription_offers

  validates :duration, presence: true, allow_blank: false,
                       numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, allow_blank: false,
                    numericality: { greater_than: 0, only_integer: true, message: 'Must be a positive
                     number. Maximum 2 numbers after comma' }

  default_scope { where(deleted_at: nil) }

  def soft_delete
    update(deleted_at: Time.zone.now) if deleted_at.nil?
  end
end
