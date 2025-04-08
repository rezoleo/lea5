# How to upgrade Rails version

You can use the ["Upgrade to Rails 7.1" pull request][upgrade-7-1-pr] as an example.

1. Update version number in Gemfile
2. Run `bundle update rails`
3. Run `bin/rails app:update`
   1. You can check the diff for each file that will be overwritten, or wait at the end and use git to check
   2. Make sure you fix Rubocop warnings before diffing, this will greatly reduce noise (Rails uses double quotes for strings, we mostly use single quotes)
4. Read the new stuff in `config/initializers/new_framework_defaults_<Rails version>.rb`, to see if something will affect us.
   Once you're clear, change the default in `config/application.rb`.
5. Read [Upgrading Rails][upgrading-rails] for general instructions
6. Read the release notes for the specific Rails version (e.g. [Rails 7.1 release notes][rails-7.1-release-notes])
   1. Immediately upgrade our code patterns if you find some that could benefit from new Rails features
      (e.g. Rails 7.1 added a [`ActiveRecord.normalizes`][rails-7.1-normalizes] feature that simplified our User model,
      or strict template locals to be explicit with what can be passed to a view and provide better performance)
7. Read each Rails component changelog (Railties, Action Cable, Action Pack...) linked from the global Rails version release notes
8. Generate a brand-new Rails app in another folder
   1. Run the same command as when we first generated Lea5
      ```shell
      rails new rails-7-1 --database postgresql --skip-action-cable --skip-action-mailbox --skip-action-text
      ```
   2. Install Rubocop and all plugins, copy our configuration, then run it once with autofix to remove syntactic differences between the new app and our existing code
      ```shell
      bundle add --group development rubocop rubocop-capybara rubocop-i18n rubocop-minitest rubocop-performance rubocop-rails
      cp .rubocop.yml <newly generated app>
      bundle exec rubocop -A # In the new app
      ```
   3. Compare files between the new app and Lea5 to see what would be added in a newly generated app (tip: use [Git-Delta][git-delta] or [Difftastic][difftastic] for smarter and nicer-looking diffs)
      ```shell
      # Move/remove uninteresting files and folders to reduce comparisons
      mv .git <safe location>
      mv .idea <safe location>
      mv coverage <safe location>
      bin/rails tmp:clear
      bin/rails log:clear
      rm -f tmp/miniprofiler/mp_timers_*
      rf -rf tmp/cache/bootsnap/compile-cache-iseq/*
      # Compare apps
      delta <current lea5> <newly generated app>
      difft <current lea5> <newly generated app> --skip-unchanged --sort-paths --color=always | less
      ```
      You can also use [RailsDiff][railsdiff] for another view at the changes (but the above method is preferred).

[git-delta]: https://github.com/dandavison/delta
[difftastic]: https://difftastic.wilfred.me.uk/
[rails-7.1-normalizes]: https://guides.rubyonrails.org/7_1_release_notes.html#add-activerecord-base-normalizes
[rails-7.1-release-notes]: https://edgeguides.rubyonrails.org/7_1_release_notes.html
[railsdiff]: https://railsdiff.org
[upgrade-7-1-pr]: https://github.com/rezoleo/lea5/pull/463
[upgrading-rails]: https://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html
