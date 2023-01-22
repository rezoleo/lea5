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

  test 'start_at and end_at cannot be nil' do
    @subscription.start_at = nil
    assert_not_predicate @subscription, :valid?

    @subscription.reload

    @subscription.end_at = nil
    assert_not_predicate @subscription, :valid?
  end

  test 'end_date is strictly after start_date' do
    @subscription.end_at = @subscription.start_at - 1.month
    assert_not_predicate @subscription, :valid?

    @subscription.end_at = @subscription.start_at
    assert_not_predicate @subscription, :valid?
  end

  test "cancelled_at can't be changed when not nil" do
    subscription = @user.subscriptions.new(start_at: Time.current, end_at: 1.month.from_now, cancelled_at: Time.current)
    assert_predicate subscription, :valid?
    subscription.save!

    subscription.cancelled_at = subscription.cancelled_at + 1.day
    assert_not_predicate subscription, :valid?

    subscription.cancelled_at = nil
    assert_not_predicate subscription, :valid?
  end

  test 'cancelled_at can be changed when nil' do
    subscription = @user.subscriptions.new(start_at: Time.current, end_at: 1.month.from_now)
    subscription.save

    subscription.cancelled_at = Time.current
    assert_predicate subscription, :valid?
  end

  test 'subscription should be destroyed when the user is destroyed' do
    assert_difference 'Subscription.count', -1 do
      @user.destroy
    end
  end

  test 'when cancelling a subscription, cancelled_at should be updated' do
    freeze_time

    @subscription.cancel!
    assert_equal Time.current, @subscription.cancelled_at
  end
end
