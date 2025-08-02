# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Inspired by https://nts.strzibny.name/rails-system-tests-headless/
  # :nocov:
  DRIVER = if ENV['DRIVER']
             ENV['DRIVER'].to_sym
           else
             :headless_chrome
           end
  # :nocov:

  # To pass options to the underlying driver, we need to use a block like so:
  # driven_by ..., |driver_option| do
  #   driver_option.something
  # end
  # https://rubydoc.info/gems/actionpack/7.0.4/ActionDispatch/SystemTestCase
  # :nocov:
  if ENV['CAPYBARA_SERVER_PORT']
    served_by host: 'rails-app', port: ENV['CAPYBARA_SERVER_PORT']

    capybara_options = {
      browser: :remote,
      url: "http://#{ENV.fetch('SELENIUM_HOST')}:4444"
    }
    # :nocov:
  else
    capybara_options = {}
  end
  driven_by :selenium, using: DRIVER, screen_size: [1400, 1400], options: capybara_options do |driver_option|
    # https://www.selenium.dev/documentation/webdriver/browsers/firefox/#start-browser-in-a-specified-location
    # :nocov:
    driver_option.binary = ENV['DRIVER_BINARY'] if ENV['DRIVER_BINARY']
    # :nocov:
  end

  Capybara.enable_aria_label = true
end
