# frozen_string_literal: true

require 'test_helper'

module Admin
  class PaymentMethodsControllerTest < ActionDispatch::IntegrationTest
    def setup
      @payment_method = payment_methods(:credit_card)
      @user = users(:ironman)
      sign_in_as @user, ['rezoleo']
    end

    test 'should get new' do
      get new_payment_method_path
      assert_template 'admin/payment_methods/new'
    end

    test 'should create payment_method' do
      assert_difference 'PaymentMethod.unscoped.count', 1 do
        post payment_methods_path, params: { payment_method: { name: 'Credit Card', auto_verify: true } }
      end
      assert_redirected_to admin_path
    end

    test 'should re-render if missing payment_method information' do
      assert_no_difference 'PaymentMethod.unscoped.count' do
        post payment_methods_path, params: { payment_method: { name: nil } }
      end

      assert_template 'admin/payment_methods/new'
    end

    test 'should not destroy payment_method if soft_delete' do
      assert_no_difference 'PaymentMethod.unscoped.count' do
        @payment_method.soft_delete
      end
    end

    test 'should soft_delete payment_method' do
      assert_no_difference 'PaymentMethod.unscoped.count' do
        delete payment_method_path(@payment_method)
      end
      assert_redirected_to admin_path
    end
  end
end
