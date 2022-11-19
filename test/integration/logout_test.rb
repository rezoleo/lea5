# frozen_string_literal: true

require 'test_helper'

class LogoutTest < ActionDispatch::IntegrationTest
  def setup
    sign_in_as users(:ironman)
  end

  test 'user should be logged out when deleting session' do
    assert_predicate self, :logged_in?

    delete logout_path

    assert_not logged_in?
  end

  test 'user should be logged out after certain time' do
    assert_predicate self, :logged_in?

    travel SESSION_DURATION_TIME + 1.second # Add 1 second to duration to prevent edge case of exact time

    get users_path
    assert_not logged_in?
  end
end
