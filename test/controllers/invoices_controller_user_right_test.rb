# frozen_string_literal: true

require 'test_helper'

class InvoicesControllerUserRightTest < ActionDispatch::IntegrationTest
  def setup
    super
    @user = users(:pepper)
    @admin = users(:ironman)
    @user_invoice = invoices(:sale_pepper_1_year)
    @other_invoice = invoices(:sale_ironman_cable_6_months)
  end

  test 'non-admin user can download their own invoice' do
    sign_in_as @user

    get download_invoice_path(@user_invoice)

    assert_response :redirect
  end

  test 'non-admin user cannot download someone else invoice' do
    sign_in_as @user

    assert_raises CanCan::AccessDenied do
      get download_invoice_path(@other_invoice)
    end
  end

  test 'admin can download any invoice' do
    sign_in_as @admin, ['rezoleo']

    get download_invoice_path(@user_invoice)

    assert_response :redirect
  end
end
