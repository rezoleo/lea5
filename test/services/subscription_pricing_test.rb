# frozen_string_literal: true

require 'test_helper'

class SubscriptionPricingTest < ActiveSupport::TestCase
  # Sellable fixtures: month (1 month / 5 €), year (12 months / 50 €).

  test 'basket_for returns nothing for a non-positive duration' do
    assert_empty SubscriptionPricing.basket_for(0)
    assert_empty SubscriptionPricing.basket_for(-3)
  end

  test 'basket_for decomposes greedily, largest offer first' do
    basket = SubscriptionPricing.basket_for(14)

    by_offer = basket.to_h { |sso| [sso.subscription_offer_id, sso.quantity] }
    assert_equal 1, by_offer[subscription_offers(:year).id]
    assert_equal 2, by_offer[subscription_offers(:month).id]
  end

  test 'basket_for leaves no remainder uncovered when an offer cannot fit' do
    basket = SubscriptionPricing.basket_for(11)

    assert_equal 1, basket.length
    assert_equal subscription_offers(:month).id, basket.first.subscription_offer_id
    assert_equal 11, basket.first.quantity
  end

  test 'cost_for is zero for a non-positive duration' do
    assert_equal Money.new(0, :eur), SubscriptionPricing.cost_for(0)
    assert_equal Money.new(0, :eur), SubscriptionPricing.cost_for(-1)
  end

  test 'cost_for prices the greedy decomposition' do
    assert_equal Money.new(5000, :eur), SubscriptionPricing.cost_for(12)
    assert_equal Money.new(6000, :eur), SubscriptionPricing.cost_for(14) # 1 year + 2 months
    assert_equal Money.new(500, :eur), SubscriptionPricing.cost_for(1)
  end

  test 'cost_for rounds the remainder up to the smallest sellable offer' do
    subscription_offers(:month).soft_delete # only the 12-month offer remains sellable

    # 5 months cannot be tiled by a 12-month offer, so round up to one full year.
    assert_equal Money.new(5000, :eur), SubscriptionPricing.cost_for(5)
  end

  test 'cost_for raises when no offer is sellable' do
    SubscriptionOffer.find_each(&:soft_delete)

    assert_raises(SubscriptionPricing::NoSellableOfferError) do
      SubscriptionPricing.cost_for(1)
    end
  end
end
