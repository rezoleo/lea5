# frozen_string_literal: true

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    super
    @user = users(:ironman)
    @subscription = subscriptions(:subscription1)
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

  test 'refundable? only when still running and not cancelled' do
    travel_to Time.zone.local(2023, 3, 1, 12) do
      running = Subscription.new(start_at: Time.zone.local(2023, 1, 1), end_at: Time.zone.local(2023, 6, 1))
      assert_predicate running, :refundable?

      # Not yet started but still valid in the future
      future = Subscription.new(start_at: Time.zone.local(2099, 1, 1), end_at: Time.zone.local(2099, 6, 1))
      assert_predicate future, :refundable?

      over = Subscription.new(start_at: Time.zone.local(2022, 1, 1), end_at: Time.zone.local(2022, 6, 1))
      assert_not_predicate over, :refundable?

      cancelled = Subscription.new(start_at: Time.zone.local(2023, 1, 1), end_at: Time.zone.local(2023, 6, 1),
                                   cancelled_at: Time.zone.local(2023, 2, 1))
      assert_not_predicate cancelled, :refundable?
    end
  end

  test 'consumed_months is zero before the subscription starts' do
    subscription = Subscription.new(start_at: Time.zone.local(2023, 1, 1, 12))

    assert_equal 0, subscription.consumed_months(as_of: Time.zone.local(2022, 12, 31, 12))
    assert_equal 0, subscription.consumed_months(as_of: Time.zone.local(2023, 1, 1, 12))
  end

  test 'consumed_months respects the 7-day grace period' do
    subscription = Subscription.new(start_at: Time.zone.local(2023, 1, 1, 12))

    # First month: fully refundable during the first week
    assert_equal 0, subscription.consumed_months(as_of: Time.zone.local(2023, 1, 8, 11, 59, 59))
    assert_equal 1, subscription.consumed_months(as_of: Time.zone.local(2023, 1, 8, 12, 0, 1))

    # Second month: another one-week grace period
    assert_equal 1, subscription.consumed_months(as_of: Time.zone.local(2023, 2, 8, 11, 59, 59))
    assert_equal 2, subscription.consumed_months(as_of: Time.zone.local(2023, 2, 8, 12, 0, 1))
  end

  test 'paid sums the price of the subscription offers in the sale' do
    # subscription2 -> pepper_1_year -> 1 year offer (50 €)
    assert_equal Money.new(5000, :eur), subscriptions(:subscription2).paid
  end

  test 'refund_amount gives a full refund before the subscription starts' do
    subscription = subscriptions(:subscription2) # paid 50 €, starts 2023-01-07

    assert_equal Money.new(5000, :eur), subscription.refund_amount(as_of: Time.zone.local(2023, 1, 1, 12))
  end

  test 'refund_amount is paid minus the cost of consumed months' do
    subscription = subscriptions(:subscription2) # paid 50 €, starts 2023-01-07

    # 3 months + 8 days -> 4 consumed months -> 4 × 5 € = 20 € consumed -> 30 € refunded
    assert_equal Money.new(3000, :eur), subscription.refund_amount(as_of: Time.zone.local(2023, 4, 15, 12))
  end

  test 'refund_amount is floored at zero when consumed cost exceeds what was paid' do
    subscription = subscriptions(:subscription2) # paid 50 €, starts 2023-01-07

    # 14 consumed months -> 1 year + 2 months = 60 € > 50 € paid -> floored at 0
    assert_equal Money.new(0, :eur), subscription.refund_amount(as_of: Time.zone.local(2024, 2, 8, 12))
  end

  # test "cancelled_at can't be changed when not nil" do
  #   subscription = @user.subscriptions.new(start_at: Time.current,
  # end_at: 1.month.from_now, cancelled_at: Time.current)
  #   assert_predicate subscription, :valid?
  #   subscription.save!
  #
  #   subscription.cancelled_at = subscription.cancelled_at + 1.day
  #   assert_not_predicate subscription, :valid?
  #
  #   subscription.cancelled_at = nil
  #   assert_not_predicate subscription, :valid?
  # end
  #
  # test 'cancelled_at can be changed when nil' do
  #   subscription = @user.subscriptions.new(start_at: Time.current, end_at: 1.month.from_now)
  #   subscription.save
  #
  #   subscription.cancelled_at = Time.current
  #   assert_predicate subscription, :valid?
  # end
  #
  # test 'subscription should be destroyed when the user is destroyed' do
  #   assert_difference 'Subscription.count', -1 do
  #     @user.destroy
  #   end
  # end

  # test 'when cancelling a subscription, cancelled_at should be updated' do
  #   freeze_time
  #
  #   @subscription.cancel!
  #   assert_equal Time.current, @subscription.cancelled_at
  # end

  # test 'duration should give months' do
  #   freeze_time
  #
  #   subscription = @user.subscriptions.create(start_at: Time.current, end_at: 8.months.from_now)
  #   subscription.reload
  #   assert_equal 8, subscription.duration
  #
  #   subscription = @user.subscriptions.create(start_at: Time.current, end_at: 13.months.from_now)
  #   subscription.reload
  #   assert_equal 13, subscription.duration
  #
  #   travel_to Time.zone.local(2024, 5, 31)
  #
  #   subscription = @user.subscriptions.create(start_at: Time.current, end_at: 8.months.from_now)
  #   subscription.reload
  #   assert_equal 8, subscription.duration
  #
  #   subscription = @user.subscriptions.create(start_at: Time.current, end_at: 13.months.from_now)
  #   subscription.reload
  #   assert_equal 13, subscription.duration
  # end
end
