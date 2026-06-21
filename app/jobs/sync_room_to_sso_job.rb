# frozen_string_literal: true

class SyncRoomToSsoJob < ApplicationJob
  queue_as :default

  retry_on SsoHttpClient::TimeoutError, wait: 30.seconds, attempts: 5

  def perform(user_id)
    user = User.find_by(id: user_id)
    return if user.nil?

    SsoMetadataService.new.sync_room(user)
  end
end
