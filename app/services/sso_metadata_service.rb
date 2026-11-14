# frozen_string_literal: true

class SsoMetadataService < SsoHttpClient
  # @param user [User]
  def sync_room(user)
    return if user.oidc_id.blank?

    room_number = user.room&.number

    unless production?
      Rails.logger.info("SSO dry-run: would sync room '#{room_number}' for user #{user.oidc_id}")
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
    body = { metadata: [{ key: 'room', value: Base64.strict_encode64(room_number) }] }

    req = build_request(Net::HTTP::Post, "/v2/users/#{user.oidc_id}/metadata", body:)
    res = execute_request(context: "room metadata for user #{user.oidc_id}", request: req)

    return if res.is_a?(Net::HTTPSuccess)

    fail_with_response!(context: "room metadata for user #{user.oidc_id}", request: req, response: res)
  end

  def delete_room_metadata(user)
    req = build_request(
      Net::HTTP::Delete,
      "/v2/users/#{user.oidc_id}/metadata",
      query: [['keys', 'room']]
    )
    res = execute_request(context: "room metadata for user #{user.oidc_id}", request: req)

    return if res.is_a?(Net::HTTPSuccess) || res.is_a?(Net::HTTPNotFound) # NotFound => No existing metadata to delete

    fail_with_response!(context: "room metadata for user #{user.oidc_id}", request: req, response: res)
  end
end
