# frozen_string_literal: true

require 'test_helper'

module Admin
  class AccountingControllerTest < ActionDispatch::IntegrationTest
    def setup
      super
      @user = users(:ironman)
      sign_in_as @user, ['rezoleo']
    end

    test 'should show accounting dashboard' do
      get admin_accounting_path
      assert_response :success
      assert_template 'admin/accounting/index'
    end

    test 'should handle different period parameters' do
      ['current_month', 'last_month', 'last_30_days', 'current_year', 'last_year', 'all_time'].each do |period|
        get admin_accounting_path, params: { period: period }
        assert_response :success
      end
    end

    test 'should handle custom date range' do
      get admin_accounting_path, params: {
        period: 'custom',
        start_date: '2024-01-01',
        end_date: '2024-12-31'
      }
      assert_response :success
    end

    test 'should export csv' do
      get export_csv_admin_accounting_path
      assert_response :success
      assert_equal 'text/csv', response.content_type
    end
  end
end
