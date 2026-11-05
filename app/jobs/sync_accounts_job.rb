# frozen_string_literal: true

class SyncAccountsJob < ApplicationJob
  queue_as :default

  retry_on SsoHttpClient::TimeoutError, wait: 1.minute, attempts: 3

  def perform
    sso_users = SsoUsersService.new.all

    User.where.not(oidc_id: nil).find_each do |user|
      if sso_users.key?(user.oidc_id)
        update_user(user, sso_users[user.oidc_id])
      else
        deactivate_user(user)
      end
    end
  end

  private

  def update_user(user, sso_user)
    return if sso_user.nil?

    if user.update_from_sso(**sso_user.slice(:firstname, :lastname, :email, :username))
      Rails.logger.info "Updated #{user.username}"
    else
      Rails.logger.error "Error updating user #{user.username}"
    end
  end

  def deactivate_user(user)
    username = user.username
    if user.deactivate_from_sso
      Rails.logger.info "Deactivated #{username}"
    else
      # :nocov:
      Rails.logger.error "Error deactivating user #{username}"
      # :nocov:
    end
  end
end
