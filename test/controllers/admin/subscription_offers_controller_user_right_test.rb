# frozen_string_literal: true

require 'test_helper'

module Admin
  class SubscriptionOffersControllerUserRightTest < ActionDispatch::IntegrationTest
    def setup
      super
      @user = users(:pepper)
      sign_in_as @user

      @subscription_offer = subscription_offers(:month)
    end

    test 'non-admin user should not see subscription offer creation page' do
      get new_subscription_offer_path
      assert_response :forbidden
    end

    test 'non-admin user should not create a new subscription offer' do
      post subscription_offers_path params: { subscription_offer: { duration: 1, price: 5.00 } }
      assert_response :forbidden
    end

    test 'non-admin user should not delete a subscription offer' do
      delete subscription_offer_path @subscription_offer
      assert_response :forbidden
    end
  end
end
