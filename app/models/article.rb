# frozen_string_literal: true

class Article < ApplicationRecord
  has_many :articles_sales, dependent: :restrict_with_error
  has_many :sales, through: :articles_sales
  has_many :articles_refunds, dependent: :restrict_with_error
  has_many :refunds, through: :articles_refunds

  monetize :price_cents, numericality: { greater_than: 0 }

  validates :name, presence: true, allow_blank: false
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
