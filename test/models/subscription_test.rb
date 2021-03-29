# frozen_string_literal: true

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    @subscription = subscriptions(:two_months)
  end

  test 'subscription is valid' do
    assert @subscription.valid?
  end

  test "duration can't be nil" do
    @subscription.duration = nil
    assert_not @subscription.valid?
  end

  test 'duration must be an integer' do
    @subscription.duration = 3.12
    assert_not @subscription.valid?
  end

  test 'duration must be strictly positive' do
    @subscription.duration = -1
    assert_not @subscription.valid?
    @subscription.duration = 0
    assert_not @subscription.valid?
  end

  test 'price must be of the correct value' do
    @subscription.duration = 4
    assert_equal 4 * Subscription.monthly_price, @subscription.price
    @subscription.duration = 15
    assert_equal 1 * Subscription.yearly_price + 3 * Subscription.monthly_price, @subscription.price
  end

  test 'cancelled should be false by default' do
    subscription = Subscription.new(duration: 3)
    assert_not subscription.cancelled
  end

  test 'cancelled_date should be set with a method' do
    subscription = Subscription.new(duration: 3)
    assert_nil subscription.cancelled_date
    time_before_cancelled = DateTime.now
    subscription.toggle_cancelled
    time_after_cancelled = DateTime.now
    puts subscription.inspect
    puts subscription.cancelled_date
    assert time_before_cancelled <= subscription.cancelled_date && subscription.cancelled_date <= time_after_cancelled
    assert subscription.cancelled
  end
end
