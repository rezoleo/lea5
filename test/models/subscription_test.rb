# frozen_string_literal: true

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    @user = users(:ironman)
    @subscription = subscriptions(:one)
  end

  test 'subscription is valid' do
    assert_predicate @subscription, :valid?
  end

  test "duration can't be changed" do
    @subscription.duration = 8
    assert_not_predicate @subscription, :valid?
  end

  test "duration can't be nil" do
    subscription = @user.subscriptions.new(duration: nil)
    assert_not_predicate subscription, :valid?
  end

  test 'duration must be integer' do
    subscription = @user.subscriptions.new(duration: 1.1)
    assert_not_predicate subscription, :valid?
  end

  test 'duration must be strictly positive' do
    subscription = @user.subscriptions.new(duration: 0)
    assert_not_predicate subscription, :valid?

    subscription = @user.subscriptions.new(duration: -1)
    assert_not_predicate subscription, :valid?
  end

  test "cancelled_at can't be changed when not nil" do
    subscription = @user.subscriptions.new(duration: 2, cancelled_at: DateTime.now)
    subscription.save

    subscription.cancelled_at = subscription.cancelled_at + 1.day
    assert_not_predicate subscription, :valid?

    subscription.cancelled_at = nil
    assert_not_predicate subscription, :valid?
  end

  test 'cancelled_at can be changed when nil' do
    subscription = @user.subscriptions.new(duration: 2)
    subscription.save

    subscription.cancelled_at = DateTime.now
    assert_predicate subscription, :valid?
  end

  test 'subscription should be destroyed when the user is destroyed' do
    assert_difference 'Subscription.count', -1 do
      @user.destroy
    end
  end

  test 'when extending a valid subscription expiration,it should be extend by duration' do
    freeze_time
    @user.subscription_expiration = DateTime.now + 1.month

    new_subscription_expiration = @subscription.extend_subscription(@user.subscription_expiration)
    assert_equal @user.subscription_expiration + @subscription.duration.month, new_subscription_expiration
  end

  test 'when extending an expired subscription expiration,it should be now + duration' do
    freeze_time
    @user.subscription_expiration = DateTime.now - 1.month

    new_subscription_expiration = @subscription.extend_subscription(@user.subscription_expiration)
    assert_equal DateTime.now + @subscription.duration.month, new_subscription_expiration
  end

  test 'when extending a nil subscription expiration,it should be now + duration' do
    freeze_time
    @user.subscription_expiration = nil

    new_subscription_expiration = @subscription.extend_subscription(@user.subscription_expiration)
    assert_equal DateTime.now + @subscription.duration.month, new_subscription_expiration
  end
end
