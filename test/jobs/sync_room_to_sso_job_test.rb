# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

class SyncRoomToSsoJobTest < ActiveJob::TestCase
  test 'performs sync for existing user' do
    user = users(:ironman)
    output = StringIO.new
    logger = ActiveSupport::Logger.new(output)
    old_logger = Rails.logger

    Rails.logger = logger
    begin
      perform_enqueued_jobs do
        SyncRoomToSsoJob.perform_later(user.id)
      end
    ensure
      Rails.logger = old_logger
    end

    assert_includes output.string, 'SSO dry-run: would sync room'
  end

  test 'does nothing when user does not exist' do
    missing_user_id = User.maximum(:id).to_i + 1
    output = StringIO.new
    logger = ActiveSupport::Logger.new(output)
    old_logger = Rails.logger

    Rails.logger = logger
    begin
      perform_enqueued_jobs do
        SyncRoomToSsoJob.perform_later(missing_user_id)
      end
    ensure
      Rails.logger = old_logger
    end

    assert_not_includes output.string, 'SSO dry-run: would sync room'
  end

  test 'retries on SSO HTTP errors' do
    failing_service = Object.new
    failing_service.define_singleton_method(:sync_room) { |_user| raise SsoHttpClient::HttpError, 'status 500' }

    SsoMetadataService.stub :new, failing_service do
      assert_enqueued_with(job: SyncRoomToSsoJob) do
        SyncRoomToSsoJob.perform_now(users(:ironman).id)
      end
    end
  end
end
