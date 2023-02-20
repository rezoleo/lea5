# frozen_string_literal: true

require 'test_helper'

class SubscriptionsControllerUserRightTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:pepper)
    @admin = users(:ironman)
    sign_in_as @user
  end

  test 'non-admin user should not see subscription creation page' do
    assert_raises CanCan::AccessDenied do
      get new_user_subscription_path @user
    end
  end

  test 'non-admin user should not create a new subscription' do
    assert_raises CanCan::AccessDenied do
      post user_subscriptions_url @user, params: { subscription: { duration: 8 } }
    end
  end

  test 'non-admin user should not delete a new subscription' do
    assert_raises CanCan::AccessDenied do
      delete user_last_subscription_url @user
    end
  end
end
