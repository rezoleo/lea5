# frozen_string_literal: true

class SubscriptionOffer < ApplicationRecord
  has_many :sales_subscription_offers, dependent: :restrict_with_error
  has_many :sales, through: :sales_subscription_offers
  has_many :refunds_subscription_offers, dependent: :restrict_with_error
  has_many :refunds, through: :refunds_subscription_offers

  monetize :price_cents, numericality: { greater_than: 0 }

  validates :duration, presence: true, allow_blank: false,
                       numericality: { only_integer: true, greater_than: 0 }
  validate :price_currency_is_default

  scope :sellable, -> { where(deleted_at: nil) }

  def soft_delete
    update(deleted_at: Time.zone.now) if deleted_at.nil?
  end

  private

  def price_currency_is_default
    return if price.nil?

    errors.add(:price, "must be in #{Money.default_currency}") if price.currency != Money.default_currency
  end
end
