# frozen_string_literal: true

require 'test_helper'

class SubscriptionOfferTest < ActiveSupport::TestCase
  def setup
    super
    @subscription_offer = subscription_offers(:month)
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

  test 'duration should be strictly positive' do
    @subscription_offer.duration = -5
    assert_not_predicate @subscription_offer, :valid?

    @subscription_offer.duration = 0
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

  test 'price should be strictly positive' do
    @subscription_offer.price = -5
    assert_not_predicate @subscription_offer, :valid?

    @subscription_offer.price = 0
    assert_not_predicate @subscription_offer, :valid?
  end

  test 'offer should soft delete' do
    @subscription_offer.deleted_at = nil
    assert_no_difference 'SubscriptionOffer.unscoped.count' do
      @subscription_offer.soft_delete
    end
    assert_not_predicate @subscription_offer.deleted_at, :nil?
  end

  test 'soft_delete should not change deleted_at date' do
    @subscription_offer.deleted_at = 3.days.ago
    before_test = @subscription_offer.deleted_at
    @subscription_offer.soft_delete
    assert_equal @subscription_offer.deleted_at, before_test
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
