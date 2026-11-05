# frozen_string_literal: true

Rails.application.configure do
  # Jobs run in the web process: volume is low, so no dedicated worker.
  config.good_job.execution_mode = :async
  config.good_job.max_threads = 2
  config.good_job.preserve_job_records = true
  config.good_job.cleanup_preserved_jobs_before_seconds_ago = 14.days.to_i
  config.good_job.enable_cron = Rails.env.production?
  config.good_job.cron = {
    sync_accounts: { cron: '0 */3 * * *', class: 'SyncAccountsJob' }
  }
end
