# frozen_string_literal: true

require 'simplecov'
# SimpleCov configuration was moved to `.simplecov`
# https://github.com/simplecov-ruby/simplecov#using-simplecov-for-centralized-config

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'
# :nocov:
if ENV['CI']
  Minitest::Reporters.use! [
    Minitest::Reporters::DefaultReporter.new(color: true),
    Minitest::Reporters::JUnitReporter.new
  ]
else
  Minitest::Reporters.use! unless ENV['RM_INFO']
end
# :nocov:

require 'webmock/minitest'
WebMock.disable_net_connect!(
  allow_localhost: true
)

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Fix simplecov setup when running tests in parallel
    # https://github.com/simplecov-ruby/simplecov/issues/718#issuecomment-538201587
    parallelize_setup do |worker|
      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end

    parallelize_teardown do |_worker|
      SimpleCov.result
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    include SessionsHelper

    OmniAuth.config.test_mode = true

    def setup
      super
      # Reset OmniAuth mocks to a clean state, to keep each test independent
      OmniAuth.config.mock_auth[:keycloak] = nil
      OmniAuth.config.mock_auth[:developer] = nil
    end

    # @param [User] user
    # @param [Array<String>] groups
    def sign_in_as(user, groups = [])
      setup_auth_conf_for(user, groups)
      sign_in
    end

    # @param [User] user
    # @param [Array<String>] groups
    def setup_auth_conf_for(user, groups)
      OmniAuth.config.add_mock(
        :keycloak,
        {
          provider: 'keycloak',
          uid: user.keycloak_id,
          info: {
            first_name: user.firstname,
            last_name: user.lastname,
            email: user.email
          },
          extra: {
            raw_info: {
              room: user.room,
              groups: groups,
              preferred_username: "#{user.firstname}-#{user.lastname}"
            }
          }
        }
      )
    end

    # Depending on the test running, the methods are different to sign out
    def sign_out
      if is_a? ActionDispatch::IntegrationTest
        delete logout_path
      elsif is_a? ApplicationSystemTestCase
        click_on 'Logout'
        # `click_on` doesn't wait for whatever is run by the click to end,
        # so we wait until the 'Login' button is visible (<=> we went through
        # the logout process).
        find_button 'Login'
      end
    end

    private

    # Depending on the test running, the methods are different to sign in
    def sign_in
      if is_a? ActionDispatch::IntegrationTest
        get auth_callback_path
      elsif is_a? ApplicationSystemTestCase
        visit root_path # We must first visit a page to click on the button
        click_on 'Login'
        # `click_on` doesn't wait for whatever is run by the click to end,
        # so we wait until the 'Logout' button is visible (<=> we went through
        # the login process).
        find_button 'Logout'
      end
    end
  end
end
