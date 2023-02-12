# frozen_string_literal: true

require 'test_helper'

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @subscription = subscriptions(:subscription1)
    @owner = @subscription.user
    sign_in_as @owner, ['rezoleo']
  end

  test 'should get new' do
    get new_user_subscription_path @owner
    assert_template 'subscriptions/new'
  end

  test 'should create a subscription and redirect if subscription is valid' do
    assert_difference 'Subscription.count', 1 do
      post user_subscriptions_url @owner, params: { subscription: { duration: 8 } }
    end

    assert_redirected_to @owner
  end

  test 'should extend user subscription expiration on create' do
    freeze_time
    @owner.extend_subscription(duration: 2)
    @owner.save
    old_subscription_expiration = @owner.subscription_expiration

    post user_subscriptions_url @owner, params: { subscription: { duration: 8 } }

    assert_equal old_subscription_expiration + 8.months, @owner.subscription_expiration
  end

  test 'should re-render new if subscription is invalid' do
    post user_subscriptions_url @owner, params: { subscription: { duration: -1 } }
    assert_template 'subscriptions/new'
  end

  test 'should cancel without deleting a subscription and redirect to owner' do
    assert_no_difference 'Subscription.count' do
      delete subscription_url @subscription
    end
    assert_redirected_to user_url @owner
  end

  test 'should reduce user subscription expiration on cancel' do
    freeze_time
    @owner.extend_subscription(duration: 2)
    @owner.save
    @owner.extend_subscription(duration: 3) # subscription to be cancelled
    @owner.save
    assert_equal 5.months.from_now, @owner.subscription_expiration

    delete subscription_url @owner.current_subscription

    assert_equal 2.months.from_now, @owner.subscription_expiration
  end
end
