# frozen_string_literal: true

SimpleCov.start 'rails' do
  enable_coverage :branch

  # TODO: Enable this after merging Ruby updates and adding tests to increase coverage
  # enable_coverage_for_eval
  # track_files 'app/views/**/*.erb'
  # add_group 'Views', 'app/views'

  add_group 'Services', 'app/services/'
  add_group 'API', 'app/controllers/api/'
  add_group 'CanCanCan Abilities', 'app/abilities/'

  # Loading SimpleCov as early as in the `bin/rails` file makes the Rakefile appear
  # in the coverage, and we don't need it.
  add_filter 'Rakefile'

  # Ensure 100% "code coverage" on test files, to make sure they are actually run
  # (if a test file name doesn't end with _test.rb it will be silently ignored)
  # Simplecov adds default filters to ignore test folders, we need to remove them
  # https://github.com/simplecov-ruby/simplecov/blob/main/lib/simplecov/profiles/rails.rb#L4
  # https://github.com/simplecov-ruby/simplecov/blob/main/lib/simplecov/profiles/test_frameworks.rb
  # https://github.com/simplecov-ruby/simplecov/issues/816
  # https://github.com/simplecov-ruby/simplecov/issues/803
  test_folders = Set['/test/', '/features/', '/spec/', '/autotest/']
  filters.delete_if do |f|
    f.is_a?(SimpleCov::StringFilter) && test_folders.include?(f.filter_argument)
  end

  track_files 'test/**/*.rb'
  add_group 'Tests', 'test/'

  # Add a tab in SimpleCov HTML report with ignored lines
  # Source: https://github.com/simplecov-ruby/simplecov/issues/312
  add_group 'Ignored Code' do |src_file|
    File.readlines(src_file.filename).grep(/#{SimpleCov.nocov_token}/).any?
  end

  if ENV['CI']
    require 'simplecov-cobertura'
    formatter SimpleCov::Formatter::CoberturaFormatter
  else
    formatter SimpleCov::Formatter::HTMLFormatter
  end
end
