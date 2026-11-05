# frozen_string_literal: true

namespace :lea5 do
  desc 'sync accounts from SSO (also scheduled by GoodJob cron, see config/initializers/good_job.rb)'
  task sync_accounts: [:environment] do
    SyncAccountsJob.perform_now
  end
end
