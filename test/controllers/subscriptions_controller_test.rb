# frozen_string_literal: true

require 'test_helper'

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @subscription = subscriptions(:two_months)
    @user = @subscription.user
  end

  test 'should render index' do
    get subscriptions_url
    assert_template 'subscriptions/index'
  end

  test 'should render new' do
    get new_user_subscription_path(@user)
    assert_template 'subscriptions/new'
  end

  test 'should create a subscription and redirect to user with html' do
    assert_difference 'Subscription.count', 1 do
      post user_subscriptions_url(@user, format: :html), params: {
        subscription: {
          duration: 5
        }
      }
    end
    assert_redirected_to @user
  end

  test 'should create a subscription and redirect to user with json' do
    assert_difference 'Subscription.count', 1 do
      post user_subscriptions_url(@user, format: :json), params: {
        subscription: {
          duration: 5
        }
      }
    end
    subscription = @response.parsed_body
    assert_template('subscriptions/show')
    assert_response(:created)
    assert_equal 5, subscription['duration']
    assert_equal 40, subscription['price']
    assert_not subscription['cancelled']
    assert_equal @user.id, subscription['user']['id']
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

  test 'should re-render new if subscription is invalid with html' do
    post user_subscriptions_url(@user, format: :html), params: {
      subscription: {
        duration: -1
      }
    }
    assert_template 'subscriptions/new'
  end

  test 'should send errors if subscription is invalid with json' do
    post user_subscriptions_url(@user, format: :json), params: {
      subscription: {
        duration: -1
      }
    }
    assert_response(:unprocessable_entity)
  end

  test 'should set the last subscription as cancelled and redirect to user with html' do
    assert_difference 'Subscription.count', 0 do
      delete user_subscription_url(@user, format: :html)
    end
    @user.reload
    assert @user.subscriptions.last.cancelled
    assert_redirected_to @user
  end

  test 'should set the last subscription as cancelled and send a 204 with json' do
    assert_difference 'Subscription.count', 0 do
      delete user_subscription_url(@user, format: :json)
    end
    @user.reload
    assert @user.subscriptions.last.cancelled
    assert_response :no_content
  end

  test 'should update user subscription date when last subscription is cancelled' do
    sub = @user.subscriptions.new(duration: 7)
    sub.save

    @user.handle_new_date_end_subscription(sub.duration)
    subscription_date_before_deletion = @user.date_end_subscription
    @user.save

    delete user_subscription_url(@user)

    @user.reload
    assert_equal (subscription_date_before_deletion - 7.months).utc.round,
                 @user.date_end_subscription.utc.round
  end

  test 'should set date end subscription to nil if the last subscription is cancelled' do
    assert_equal 1, @user.subscriptions.count

    assert_not_nil @user.date_end_subscription

    delete user_subscription_url(@user)

    @user.reload
    assert_nil @user.date_end_subscription
  end

  test 'should cancel the last not cancelled subscription' do
    @user.subscriptions.new(duration: 6)
    @user.subscriptions.new(duration: 4)
    @user.save

    delete user_subscription_url(@user)
    delete user_subscription_url(@user)
    @user.reload

    last_subscription = @user.subscriptions.last
    second_to_last_subscription = @user.subscriptions.second_to_last
    assert last_subscription.cancelled
    assert second_to_last_subscription.cancelled
  end

  test 'should redirect to users if there is no subscription to cancel with html' do
    @user.subscriptions.destroy_all
    assert_nil @user.subscriptions.last
    delete user_subscription_url(@user, format: :html)
    assert_redirected_to @user
  end

  test 'should send an error if there is no subscription to cancel with json' do
    @user.subscriptions.destroy_all
    assert_nil @user.subscriptions.last
    delete user_subscription_url(@user, format: :json)
    assert_response :unprocessable_entity
    assert_not_nil @response.parsed_body['error']
  end
end
