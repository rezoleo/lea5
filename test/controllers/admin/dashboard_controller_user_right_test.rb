# frozen_string_literal: true

require 'test_helper'

module Admin
  class DashboardControllerUserRightTest < ActionDispatch::IntegrationTest
    def setup
      @user = users(:pepper)
      sign_in_as @user
    end

    test 'non-admin user should not see the dashboard page' do
      assert_raises CanCan::AccessDenied do
        get admin_path
      end
    end
  end
end
