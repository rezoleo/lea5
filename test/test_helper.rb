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
      OmniAuth.config.add_mock(:keycloak, { provider: 'keycloak',
                                            uid: user.keycloak_id,
                                            info: { first_name: user.firstname,
                                                    last_name: user.lastname,
                                                    email: user.email },
                                            extra: { raw_info: { room: user.room } } })
      sign_in
    end

    private

    def sign_in
      get auth_callback_path
    end
  end
end
