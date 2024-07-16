# frozen_string_literal: true

require 'test_helper'

module Admin
  class SubscriptionOffersControllerTest < ActionDispatch::IntegrationTest
    def setup
      @subscription_offer = subscription_offers(:one)
      @user = users(:ironman)
      sign_in_as @user, ['rezoleo']
    end

    test 'should get new' do
      get new_subscription_offer_path
      assert_template 'admin/subscription_offers/new'
    end

    test 'should create offer' do
      assert_difference 'SubscriptionOffer.unscoped.count', 1 do
        post subscription_offers_path, params: { subscription_offer: { duration: 10, price: 1456 } }
      end
      assert_redirected_to admin_path
    end

    test 'should re-render if missing offer information' do
      assert_no_difference 'SubscriptionOffer.unscoped.count' do
        post subscription_offers_path, params: { subscription_offer: { duration: nil } }
      end

      assert_template 'admin/subscription_offers/new'
    end

    test 'should not destroy offer if soft_delete' do
      assert_no_difference 'SubscriptionOffer.unscoped.count' do
        @subscription_offer.soft_delete
      end
    end

    test 'should soft_delete offer' do
      assert_no_difference 'SubscriptionOffer.unscoped.count' do
        delete subscription_offer_path(@subscription_offer)
      end
      assert_redirected_to admin_path
    end
  end
end
