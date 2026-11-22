# frozen_string_literal: true

require 'test_helper'

module Admin
  class AccountingControllerUserRightTest < ActionDispatch::IntegrationTest
    def setup
      super
      @user = users(:pepper)
      sign_in_as @user
    end

    test 'non-admin user should not see the accounting dashboard' do
      get admin_accounting_path
      assert_response :forbidden
    end

    test 'non-admin user is denied before the date parameters are parsed' do
      get admin_accounting_path, params: { period: 'custom', start_date: 'notadate' }
      assert_response :forbidden
    end
  end
end
