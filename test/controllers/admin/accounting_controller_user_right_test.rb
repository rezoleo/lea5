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
      assert_raises CanCan::AccessDenied do
        get admin_accounting_path
      end
    end

    test 'non-admin user is denied before the date parameters are parsed' do
      assert_raises CanCan::AccessDenied do
        get admin_accounting_path, params: { period: 'custom', start_date: 'notadate' }
      end
    end
  end
end
