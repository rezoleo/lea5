# frozen_string_literal: true

class SsoMetadataService
  SSO_BASE_URL = 'https://sso.rezoleo.fr'
  HTTP_OPEN_TIMEOUT_SECONDS = 5
  HTTP_READ_TIMEOUT_SECONDS = 10

  # @param user [User]
  def sync_room(user)
    return if user.oidc_id.blank?

    room_number = user.room&.number

    unless production?
      Rails.logger.info("[SSO] Dry-run: would sync room '#{room_number}' for user #{user.oidc_id}")
      return
    end

    push_room_metadata(user, room_number)
  end

  private

  def production?
    Rails.env.production?
  end

  def push_room_metadata(user, room_number)
    if room_number.present?
      post_room_metadata(user, room_number)
    else
      delete_room_metadata(user)
    end
  end

  # Metadata values in Zitadel must be base64-encoded.
  # See https://zitadel.com/docs/reference/api/user/zitadel.user.v2.UserService.SetUserMetadata
  def post_room_metadata(user, room_number)
    uri = URI("#{SSO_BASE_URL}/v2/users/#{user.oidc_id}/metadata")
    body = { metadata: [{ key: 'room', value: Base64.strict_encode64(room_number) }] }

    req = build_request(Net::HTTP::Post, uri, body:)
    res = execute_request(user:, req:)

    return if res.is_a?(Net::HTTPSuccess)

    log_failure(user, uri, req, res)
  end

  def delete_room_metadata(user)
    uri = URI("#{SSO_BASE_URL}/v2/users/#{user.oidc_id}/metadata")
    uri.query = URI.encode_www_form([['keys', 'room']])

    req = build_request(Net::HTTP::Delete, uri)
    res = execute_request(user:, req:)

    return if res.is_a?(Net::HTTPSuccess) || res.is_a?(Net::HTTPNotFound) # NotFound => No existing metadata to delete

    log_failure(user, uri, req, res)
  end

  def build_request(http_method, uri, body: nil)
    req = http_method.new(uri)
    req['Authorization'] = "Bearer #{access_token}"

    return req if body.nil?

    req.content_type = 'application/json'
    req.body = body.to_json
    req
  end

  def execute_request(user:, req:)
    Net::HTTP.start(
      req.uri.hostname,
      req.uri.port,
      use_ssl: true,
      open_timeout: HTTP_OPEN_TIMEOUT_SECONDS,
      read_timeout: HTTP_READ_TIMEOUT_SECONDS
    ) do |http|
      http.request(req)
    end
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error("[SSO] Timeout for user #{user.oidc_id}: #{e.message}")
    raise
  rescue StandardError => e
    Rails.logger.error("[SSO] Error syncing room for user #{user.oidc_id}: #{e.message}")
    raise
  end

  def log_failure(user, uri, req, res)
    Rails.logger.error(
      "[SSO] Failed to sync room for user #{user.oidc_id} " \
      "(#{req.method} #{uri}): #{res.code} #{res.body}"
    )
  end

  def access_token
    Rails.application.credentials.sso_lea5_pat!
  end
end
