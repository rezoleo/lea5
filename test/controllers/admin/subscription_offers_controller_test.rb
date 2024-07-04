# frozen_string_literal: true

require 'test_helper'

module Admin
  class SubscriptionOffersControllerTest < ActionDispatch::IntegrationTest
    test 'should get admin/payment_methods' do
      get admin_subscription_offers_admin / payment_methods_url
      assert_response :success
    end
  end
end
