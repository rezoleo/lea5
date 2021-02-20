# frozen_string_literal: true

class Subscription < ApplicationRecord
  @monthly_price = 8
  @yearly_price = 80

  belongs_to :user

  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # Definition of class instance variables
  class << self
    attr_accessor :monthly_price, :yearly_price
  end

  def price
    return unless duration

    ((duration / 12) * Subscription.yearly_price + (duration % 12) * Subscription.monthly_price)
  end

  def cancelled
    !!cancelled_date
  end

  def toggle_cancelled
    self.cancelled_date = cancelled_date ? nil : DateTime.now
  end
end
