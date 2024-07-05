# frozen_string_literal: true

require 'test_helper'

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    def setup
      @user = users(:ironman)
      sign_in_as @user, ['rezoleo']
    end

    test 'should show index' do
      get admin_path
      assert_template 'admin/dashboard/index'
    end
  end
end
