# frozen_string_literal: true

require 'test_helper'

class SyncRoomToSsoJobTest < ActiveJob::TestCase
  test 'performs sync for existing user' do
    user = users(:ironman)
    output = StringIO.new
    logger = ActiveSupport::Logger.new(output)
    old_logger = Rails.logger

    Rails.logger = logger
    begin
      SyncRoomToSsoJob.perform_now(user.id)
    ensure
      Rails.logger = old_logger
    end

    assert_includes output.string, '[SSO] Dry-run: would sync room'
  end

  test 'does nothing when user does not exist' do
    missing_user_id = User.maximum(:id).to_i + 1
    output = StringIO.new
    logger = ActiveSupport::Logger.new(output)
    old_logger = Rails.logger

    Rails.logger = logger
    begin
      assert_nothing_raised do
        SyncRoomToSsoJob.perform_now(missing_user_id)
      end
    ensure
      Rails.logger = old_logger
    end

    assert_not_includes output.string, '[SSO] Dry-run: would sync room'
  end
end
