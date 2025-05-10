# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.2.2', '>= 7.2.2.1'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails', '~> 3.5'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.5'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.6'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails', '~> 1.2'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails', '~> 2.0'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails', '~> 1.3'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder', '~> 2.13'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:windows, :jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'ipaddress', '~> 0.8.3'

gem 'omniauth', '~> 2.1'
gem 'omniauth_openid_connect', '~> 0.8.0'
gem 'omniauth-rails_csrf_protection', '~> 1.0'

gem 'cancancan', '~> 3.6'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Generate pdf files [https://github.com/gettalong/hexapdf]
gem 'hexapdf', '~> 1.2.0'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: [:mri, :windows], require: 'debug/prelude'

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'brakeman', '~> 7.0', require: false
end

group :development do
  gem 'overcommit', '~> 0.67.1'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem 'rack-mini-profiler', '~> 3.3'

  gem 'rubocop', '~> 1.75'
  gem 'rubocop-capybara', '~> 2.22'
  gem 'rubocop-i18n', '~> 3.2'
  gem 'rubocop-minitest', '~> 0.38.0'
  gem 'rubocop-performance', '~> 1.24'
  gem 'rubocop-rails', '~> 2.30'
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console', '~> 4.2'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara', '~> 3.40'
  gem 'guard', '~> 2.19'
  gem 'guard-minitest', '~> 2.4'
  gem 'minitest', '~> 5.25'
  gem 'minitest-reporters', '~> 1.7'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'selenium-webdriver'
  gem 'simplecov', '~> 0.22.0'
  gem 'simplecov-cobertura', '~> 2.1'
  gem 'webmock', '~> 3.23'
end
