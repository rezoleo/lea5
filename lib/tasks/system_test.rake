# frozen_string_literal: true

# Inspired by https://nts.strzibny.name/rails-system-tests-headless/
namespace :test do
  namespace :system do
    desc 'Run system tests with Chrome (can be run headless)'
    # Syntax is task :task_name, [:list, :of, :params] => [:list, :of, :task, :dependencies]
    # Parameters are positional, so calling `rails 'test:system:chrome[something]'` will define
    # args.headless == 'something'
    task :chrome, [:headless] => [:environment] do |_task, args|
      # :nocov:
      ENV['DRIVER'] = if args.headless == 'headless'
                        'headless_chrome'
                      else
                        'chrome'
                      end
      Rake::Task['test:system'].invoke
      # :nocov:
    end

    desc 'Run system tests with Firefox (can be run headless and/or use Firefox Nightly)'
    task :firefox, [:headless, :nightly] => [:environment] do |_task, args|
      # Small (ab)use of args.to_a, normally used to retrieve a variable number of arguments
      # Since here we only care that the *strings* 'headless' or 'nightly' are passed, we convert
      # the args struct to an array of all argument values, then just check if a specific string is in it.
      # That way we can run 'test:system:firefox[nightly,headless]' or 'test:system:firefox[headless,nightly]',
      # with whichever order or combination or arguments.
      # See https://ruby.github.io/rake/doc/rakefile_rdoc.html#label-Tasks+that+take+Variable-length+Parameters
      # @type [Array<String>] args_list
      # :nocov:
      args_list = args.to_a
      ENV['DRIVER'] = if args_list.include? 'headless'
                        'headless_firefox'
                      else
                        'firefox'
                      end
      ENV['DRIVER_BINARY'] = 'firefox-nightly' if args_list.include? 'nightly'
      Rake::Task['test:system'].invoke
      # :nocov:
    end
  end
end
