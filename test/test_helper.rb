# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  enable_coverage :branch
  minimum_coverage line: 90, branch: 80
  minimum_coverage_by_file 80

  if ENV['CI']
    require 'codecov'
    formatter SimpleCov::Formatter::Codecov
  else
    formatter SimpleCov::Formatter::HTMLFormatter
  end
end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
