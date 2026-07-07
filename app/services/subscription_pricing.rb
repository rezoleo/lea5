# frozen_string_literal: true

# Decomposes and prices subscription durations using a greedy, largest-offer-first
# pass over the currently *sellable* offers.
#
# - {.basket_for} mirrors sale creation: it greedily covers as much of the requested
#   duration as possible and leaves any remainder uncovered (the caller validates
#   exhaustiveness via Sale#exhaustive_subscription_offers).
# - {.cost_for} prices a duration for refunds. Since you cannot buy a fraction of an
#   offer, a remainder that the offers cannot tile exactly is rounded *up* to the next
#   purchasable unit of the smallest offer.
class SubscriptionPricing
  class NoSellableOfferError < StandardError; end

  # @param months [Integer]
  # @return [Array<SalesSubscriptionOffer>] greedy decomposition; remainder left uncovered
  def self.basket_for(months)
    return [] if months <= 0

    remaining = months
    sellable_offers.each_with_object([]) do |offer, basket|
      quantity = remaining / offer.duration
      next unless quantity.positive?

      basket << SalesSubscriptionOffer.new(subscription_offer_id: offer.id, quantity: quantity)
      remaining -= quantity * offer.duration
    end
  end

  # @param months [Integer]
  # @return [Money] price to cover at least +months+, rounding any remainder up
  def self.cost_for(months)
    return Money.new(0) if months <= 0

    offers = sellable_offers
    raise NoSellableOfferError, 'No sellable subscription offer to price a refund' if offers.empty?

    remaining = months
    cost = Money.new(0)
    offers.each do |offer|
      quantity = remaining / offer.duration
      next unless quantity.positive?

      cost += quantity * offer.price
      remaining -= quantity * offer.duration
    end

    cost + rounded_up_remainder(offers, remaining)
  end

  def self.sellable_offers
    SubscriptionOffer.sellable.order(duration: :desc).to_a
  end
  private_class_method :sellable_offers

  # Cover a leftover duration with the smallest-duration offer, rounding up.
  def self.rounded_up_remainder(offers, remaining)
    return Money.new(0) if remaining <= 0

    smallest = offers.min_by(&:duration)
    units = (remaining.to_f / smallest.duration).ceil
    units * smallest.price
  end
  private_class_method :rounded_up_remainder
end
