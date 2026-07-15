# frozen_string_literal: true

require 'net/http'

class SsoHttpClient
  class Error < StandardError; end
  class HttpError < Error; end
  class TimeoutError < Error; end
  class RequestError < Error; end

  SSO_BASE_URI = URI('https://sso.rezoleo.fr')
  HTTP_OPEN_TIMEOUT_SECONDS = 5
  HTTP_READ_TIMEOUT_SECONDS = 10

  def initialize(access_token: nil)
    @access_token = access_token
  end

  private

  def access_token
    @access_token ||= Rails.application.credentials.sso_lea5_pat!
  end

  def sso_uri(path)
    URI.join("#{SSO_BASE_URI}/", path.delete_prefix('/'))
  end

  def build_request(http_method, path, body: nil, query: nil)
    uri = sso_uri(path)
    uri.query = URI.encode_www_form(query) if query.present?

    request = http_method.new(uri)
    request['Authorization'] = "Bearer #{access_token}"

    return request if body.nil?

    request.content_type = 'application/json'
    request.body = body.to_json
    request
  end

  def execute_request(context:, request:)
    Net::HTTP.start(
      request.uri.hostname,
      request.uri.port,
      use_ssl: true,
      open_timeout: HTTP_OPEN_TIMEOUT_SECONDS,
      read_timeout: HTTP_READ_TIMEOUT_SECONDS
    ) do |http|
      http.request(request)
    end
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    raise TimeoutError, "Timeout for #{context}: #{e.message}"
  rescue StandardError => e
    raise RequestError, "Error syncing #{context}: #{e.message}"
  end

  def fail_with_response!(context:, request:, response:)
    raise HttpError, "Failed to sync #{context} (#{request.method} #{request.uri}): #{response.code} #{response.body}"
  end
end
