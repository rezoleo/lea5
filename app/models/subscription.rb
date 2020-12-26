# frozen_string_literal: true

class Subscription < ApplicationRecord
  MONTHLY_PRICE = 8
  YEARLY_PRICE = 80

  belongs_to :user

  attr_accessor :price

  before_validation :set_price

  validates :payment, presence: true,
                      inclusion: { in: %w[cash cheque creditCard bankTransfer],
                                   message: '%<value>s is not a valid payment' }
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :date, presence: true
  validates :price, presence: true, numericality: { only_integer: true }

  validate :valid_price

  private

  def set_price
    self.price = duration / 12 * YEARLY_PRICE + duration % 12 * MONTHLY_PRICE unless duration.nil?
  end

  def valid_price
    (price % 8).zero? unless price.nil?
  end
end
