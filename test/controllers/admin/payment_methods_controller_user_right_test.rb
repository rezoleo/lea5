# frozen_string_literal: true

require 'test_helper'

module Admin
  class PaymentMethodsControllerUserRightTest < ActionDispatch::IntegrationTest
    def setup
      super
      @user = users(:pepper)
      sign_in_as @user

      @payment_method = payment_methods(:credit_card)
    end

    test 'non-admin user should not see payment method creation page' do
      get new_payment_method_path
      assert_response :forbidden
    end

    test 'non-admin user should not create a new payment method' do
      post payment_methods_path params: { payment_method: { name: 'New payment method', auto_verify: true } }
      assert_response :forbidden
    end

    test 'non-admin user should not delete a payment method' do
      delete payment_method_path @payment_method
      assert_response :forbidden
    end
  end
end
