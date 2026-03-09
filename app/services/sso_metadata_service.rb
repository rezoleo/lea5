# frozen_string_literal: true

class SsoMetadataService
  SSO_BASE_URL = 'https://sso.rezoleo.fr'

  # @param user [User]
  def self.sync_room(user)
    new.sync_room(user)
  end

  # @param user [User]
  def sync_room(user)
    return if user.oidc_id.blank?

    unless production?
      Rails.logger.info("[SSO] Dry-run: would sync room '#{user.room}' for user #{user.oidc_id}")
      return
    end

    push_room_metadata(user)
  end

  private

  def production?
    Rails.env.production?
  end

  def push_room_metadata(user)
    if user.room.present?
      post_room_metadata(user)
    else
      delete_room_metadata(user)
    end
  end

  def post_room_metadata(user)
    uri = URI("#{SSO_BASE_URL}/v2/users/#{user.oidc_id}/metadata")
    req = Net::HTTP::Post.new(uri)
    req['Authorization'] = "Bearer #{access_token}"
    req.content_type = 'application/json'
    req.body = { metadata: [{ key: 'room', value: Base64.strict_encode64(user.room) }] }.to_json

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

    unless res.is_a?(Net::HTTPSuccess)
      Rails.logger.error("[SSO] Failed to set room for user #{user.oidc_id}: #{res.code} #{res.body}")
    end
  rescue StandardError => e
    Rails.logger.error("[SSO] Error setting room for user #{user.oidc_id}: #{e.message}")
  end

  def delete_room_metadata(user)
    uri = URI("#{SSO_BASE_URL}/v2/users/#{user.oidc_id}/metadata")
    uri.query = URI.encode_www_form([['keys[]', 'room']])
    req = Net::HTTP::Delete.new(uri)
    req['Authorization'] = "Bearer #{access_token}"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

    unless res.is_a?(Net::HTTPSuccess)
      Rails.logger.error("[SSO] Failed to delete room for user #{user.oidc_id}: #{res.code} #{res.body}")
    end
  rescue StandardError => e
    Rails.logger.error("[SSO] Error deleting room for user #{user.oidc_id}: #{e.message}")
  end

  def access_token
    Rails.application.credentials.sso_lea5_pat!
  end
end
