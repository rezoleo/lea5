# frozen_string_literal: true

require 'test_helper'

class SessionExpirationTest < ActionDispatch::IntegrationTest
  test 'user should be logged out after certain time' do
    sign_in_as users(:ironman)
    assert_predicate self, :logged_in?

    travel SESSION_DURATION_TIME + 1.second # Add 1 second to duration to prevent edge case of exact time

    get users_path
    assert_not logged_in?
  end
end
