# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  enable_coverage :branch

  if ENV['CI']
    require 'simplecov-cobertura'
    formatter SimpleCov::Formatter::CoberturaFormatter
  else
    formatter SimpleCov::Formatter::HTMLFormatter
  end
end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use! unless ENV['RM_INFO']

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

    def sign_in_as(user)
      setup_auth_conf_for(user)
      sign_in
    end

    def setup_auth_conf_for(user)
      OmniAuth.config.add_mock(:keycloak, { provider: 'keycloak',
                                            uid: user.keycloak_id,
                                            info: { first_name: user.firstname,
                                                    last_name: user.lastname,
                                                    email: user.email },
                                            extra: { raw_info: { room: user.room } } })
    end

    # Depending on the test running, the methods are different to sign out
    def sign_out
      if self.class < ActionDispatch::IntegrationTest
        delete logout_path
      elsif self.class < ApplicationSystemTestCase
        click_on 'Logout'
      end
    end

    private

    # Depending on the test running, the methods are different to sign in
    def sign_in
      if self.class < ActionDispatch::IntegrationTest
        get auth_callback_path
      elsif self.class < ApplicationSystemTestCase
        visit users_path # We must first visit a page to click on the button
        click_on 'Login'
      end
    end
  end
end
