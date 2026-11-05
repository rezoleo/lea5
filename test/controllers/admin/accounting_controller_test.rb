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

    test 'should fall back to the default range when custom dates are unparseable' do
      get admin_accounting_path, params: { period: 'custom', start_date: 'notadate', end_date: ['nope'] }

      assert_response :success
      assert_equal Time.zone.now.beginning_of_month, assigns(:start_date)
      assert_equal Time.zone.now.end_of_month.end_of_day, assigns(:end_date)
    end

    test 'should fall back to the default range when custom dates are out of range' do
      get admin_accounting_path, params: { period: 'custom', start_date: '2024-13-45', end_date: '2024-13-45' }

      assert_response :success
      assert_equal Time.zone.now.beginning_of_month, assigns(:start_date)
      assert_equal Time.zone.now.end_of_month.end_of_day, assigns(:end_date)
    end

    test 'custom range covers the whole of its last day' do
      get admin_accounting_path, params: { period: 'custom', start_date: '2024-01-01', end_date: '2024-12-31' }

      assert_equal Time.zone.local(2024, 1, 1).beginning_of_day, assigns(:start_date)
      assert_equal Time.zone.local(2024, 12, 31).end_of_day, assigns(:end_date)
    end

    test 'ongoing periods stop at the current time rather than in the future' do
      get admin_accounting_path, params: { period: 'current_month' }
      assert_operator assigns(:end_date), :<=, Time.zone.now

      get admin_accounting_path, params: { period: 'current_year' }
      assert_operator assigns(:end_date), :<=, Time.zone.now
    end

    test 'all time starts at the oldest refund when it predates the oldest sale' do
      Refund.update_all(created_at: Sale.minimum(:created_at) - 1.year) # rubocop:disable Rails/SkipsModelValidations

      get export_csv_admin_accounting_path, params: { period: 'all_time' }

      assert_operator assigns(:start_date), :<=, Refund.minimum(:created_at)
      assert_includes response.body.split("\n").map { |line| line.split(';')[2] }, 'Refund'
    end

    test 'should export csv' do
      get export_csv_admin_accounting_path
      assert_response :success
      assert_equal 'text/csv', response.content_type
    end

    test 'csv export is formatted for French spreadsheets' do
      get export_csv_admin_accounting_path, params: { period: 'all_time' }

      assert response.body.start_with?("\uFEFFDate;Invoice Number;")
      assert_match(/;\d+,\d{2}\n/, response.body)
      assert_match(/\n\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2};/, response.body)
    end

    test 'csv export dates are in Paris time' do
      sale = sales(:ironman_cable_6_months)
      sale.update_column(:created_at, Time.utc(2025, 7, 1, 10, 0, 0)) # rubocop:disable Rails/SkipsModelValidations

      get export_csv_admin_accounting_path, params: { period: 'all_time' }

      # UTC+2 in summer
      assert_match(/\n2025-07-01 12:00:00;#{sale.invoice.number};Sale;/, response.body)
    end

    test 'should fall back to the default range when custom dates are missing' do
      get admin_accounting_path, params: { period: 'custom' }

      assert_response :success
      assert_equal Time.zone.now.beginning_of_month, assigns(:start_date)
      assert_equal Time.zone.now.end_of_month.end_of_day, assigns(:end_date)
    end
  end
end
