# frozen_string_literal: true

require 'test_helper'

module Admin
  class SubscriptionOffersControllerUserRightTest < ActionDispatch::IntegrationTest
    def setup
      @user = users(:pepper)
      sign_in_as @user

      @subscription_offer = subscription_offers(:month)
    end

    test 'non-admin user should not see subscription offer creation page' do
      assert_raises CanCan::AccessDenied do
        get new_subscription_offer_path
      end
    end

    test 'non-admin user should not create a new subscription offer' do
      assert_raises CanCan::AccessDenied do
        post subscription_offers_path params: { subscription_offer: { duration: 1, price: 500 } }
      end
    end

    test 'non-admin user should not delete a subscription offer' do
      assert_raises CanCan::AccessDenied do
        delete subscription_offer_path @subscription_offer
      end
    end
  end
end
