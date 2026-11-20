# frozen_string_literal: true

require 'test_helper'

module Admin
  class DashboardControllerUserRightTest < ActionDispatch::IntegrationTest
    def setup
      super
      @user = users(:pepper)
      sign_in_as @user
    end

    test 'non-admin user should not see the dashboard page' do
      get admin_path
      assert_response :forbidden
    end
  end
end
