# frozen_string_literal: true

require 'test_helper'

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @subscription = subscriptions(:two_months)
    @user = @subscription.user
  end

  test 'should render new' do
    get new_user_subscription_path(@user)
    assert_template 'subscriptions/new'
  end

  test 'should create a subscription and redirect to user' do
    assert_difference 'Subscription.count', 1 do
      post user_subscriptions_url(@user), params: {
        subscription: {
          duration: 5
        }
      }
    end
    assert_redirected_to @user
  end

  test 'should increment user subscription date when internet is still on' do
    date_end_subscription = DateTime.now + 3.months
    @user.date_end_subscription = date_end_subscription
    @user.save
    post user_subscriptions_url(@user), params: {
      subscription: {
        duration: 5
      }
    }
    @user.reload
    assert_equal (date_end_subscription + 5.months).localtime.round, @user.date_end_subscription.localtime.round
  end

  test 'should set user subscription date when internet is off' do
    @user.date_end_subscription = DateTime.now - 3.months
    @user.save
    time_before_subscription = DateTime.now
    post user_subscriptions_url(@user), params: {
      subscription: {
        duration: 5
      }
    }
    @user.reload
    time_after_subscription = DateTime.now
    assert (time_before_subscription + 5.months).localtime.round <= @user.date_end_subscription.localtime.round
    assert (time_after_subscription + 5.months).localtime.round >= @user.date_end_subscription.localtime.round
  end

  test 'should set user subscription date when internet was never given' do
    @user.date_end_subscription = nil
    @user.save
    time_before_subscription = DateTime.now
    post user_subscriptions_url(@user), params: {
      subscription: {
        duration: 5
      }
    }
    @user.reload
    time_after_subscription = DateTime.now
    assert (time_before_subscription + 5.months).localtime.round <= @user.date_end_subscription.localtime.round
    assert (time_after_subscription + 5.months).localtime.round >= @user.date_end_subscription.localtime.round
  end

  test 'should re-render new if subscription is invalid' do
    post user_subscriptions_url(@user), params: {
      subscription: {
        duration: -1
      }
    }
    assert_template 'subscriptions/new'
  end

  test 'should destroy the last subscription and redirect to user' do
    last_subscription = @user.subscriptions.last
    assert_difference 'Subscription.count', -1 do
      delete user_delete_subscription_url(@user)
    end
    @user.reload
    assert_not_equal last_subscription, @user.subscriptions.last
  end

  test 'should update user subscription date on delete' do
    sub = @user.subscriptions.new(duration: 7)
    sub.save

    @user.handle_new_date_end_subscription(sub.duration)
    subscription_date_before_deletion = @user.date_end_subscription
    @user.save

    delete user_delete_subscription_url(@user)

    @user.reload
    assert_equal (subscription_date_before_deletion - 7.months).utc.round,
                 @user.date_end_subscription.utc.round
  end

  test 'should set date end subscription to nil if the last subscriptions is deleted' do
    assert_equal 1, @user.subscriptions.count

    assert_not_nil @user.date_end_subscription

    delete user_delete_subscription_url(@user)

    @user.reload
    assert_nil @user.date_end_subscription
  end
end
