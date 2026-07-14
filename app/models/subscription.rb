# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :sale

  validates :start_at, presence: true
  validates :end_at, comparison: { greater_than: :start_at }

  def user
    sale.client
  end

  # A subscription can be refunded (cut) only while it is still valid
  # and has not already been cut by a previous refund.
  def refundable?
    cancelled_at.nil? && end_at > Time.current
  end

  # Number of months started since the purchase, as of as_of.
  # Months are measured as elapsed duration from start_at:
  # any partial month counts as a started month.
  # @return [Integer]
  def consumed_months(as_of: Time.current)
    return 0 if as_of <= start_at

    # Find the smallest number of months needed to reach or exceed the target date
    (1..).find { |months| start_at + months.months >= as_of } || 1
  end

  # Amount actually paid for this subscription's offers in its sale.
  # @return [Money]
  def paid
    total = Money.new(0)
    sale.sales_subscription_offers.each do |sso|
      total += sso.quantity * sso.subscription_offer.price
    end
    total
  end

  # Credit-note amount when cutting this subscription as of as_of: what was paid,
  # minus what the consumed (started) months would cost at current rates, floored at zero.
  # @return [Money]
  def refund_amount(as_of: Time.current)
    [paid - SubscriptionPricing.cost_for(consumed_months(as_of: as_of), at: created_at), Money.new(0)].max
  end
end
