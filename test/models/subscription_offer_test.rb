# frozen_string_literal: true

require 'test_helper'

class SubscriptionOfferTest < ActiveSupport::TestCase
  def setup
    @subscription_offer = subscription_offers(:one)
  end

  test 'should be valid' do
    assert_predicate @subscription_offer, :valid?
  end

  test 'should not be valid without duration' do
    @subscription_offer.duration = nil
    assert_not_predicate @subscription_offer, :valid?
  end

  test 'duration should be integer' do
    @subscription_offer.duration = 10.56
    assert_not_predicate @subscription_offer, :valid?
  end

  test 'duration should be positive' do
    @subscription_offer.duration = -5
    assert_not_predicate @subscription_offer, :valid?
  end

  test 'should not be valid without price' do
    @subscription_offer.price = nil
    assert_not_predicate @subscription_offer, :valid?
  end

  test 'price should be integer' do
    @subscription_offer.price = 10.56
    assert_not_predicate @subscription_offer, :valid?
  end

  test 'price should be positive' do
    @subscription_offer.price = -5
    assert_not_predicate @subscription_offer, :valid?
  end

  test 'offer should soft delete' do
    assert_no_difference 'SubscriptionOffer.unscoped.count' do
      @subscription_offer.soft_delete
    end
  end

  test 'offer should be destroyed if no sales' do
    @subscription_offer.sales.destroy_all
    @subscription_offer.refunds.destroy_all
    assert_difference 'SubscriptionOffer.unscoped.count', -1 do
      @subscription_offer.destroy
    end
  end

  test 'offer should be destroyable' do
    @subscription_offer.sales.destroy_all
    @subscription_offer.refunds.destroy_all
    assert_predicate @subscription_offer, :destroy
  end

  test 'offer should not destroy if dependant' do
    assert_no_difference 'SubscriptionOffer.unscoped.count' do
      assert_not_predicate @subscription_offer, :destroy
    end

    assert_predicate @subscription_offer, :persisted?
    assert_includes @subscription_offer.errors[:base],
                    'Cannot delete record because dependent sales subscription offers exist'
  end
end
