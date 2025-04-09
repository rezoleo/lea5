# frozen_string_literal: true

require 'test_helper'

class SalesControllerUserRightTest < ActionDispatch::IntegrationTest
  def setup
    super
    @user = users(:pepper)
    sign_in_as @user
  end

  # TODO: Add a test to ensure users can see their own sales but not others

  test 'non-admin user should not see sales creation page' do
    assert_raises CanCan::AccessDenied do
      get new_user_sale_path @user
    end
  end

  test 'non-admin user should not create a new sale' do
    assert_raises CanCan::AccessDenied do
      post user_sales_path @user, params: { sale: {
        duration: 1,
        payment_method_id: payment_methods(:credit_card).id
      } }
    end
  end
end
