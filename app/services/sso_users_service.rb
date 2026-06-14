# frozen_string_literal: true

require 'json'
require 'net/http'

class SsoUsersService
  class Error < StandardError; end
  class RequestError < Error; end
  class HttpError < RequestError; end
  class TimeoutError < RequestError; end

  LIST_USERS_URI = URI('https://sso.rezoleo.fr/v2/users')
  TEXT_QUERY_METHOD = 'TEXT_QUERY_METHOD_CONTAINS_IGNORE_CASE'
  SEARCH_LIMIT = 25
  HTTP_OPEN_TIMEOUT_SECONDS = 5
  HTTP_READ_TIMEOUT_SECONDS = 10

  def initialize(access_token: Rails.application.credentials.sso_lea5_pat!)
    @access_token = access_token
  end

  def search(query:, limit: SEARCH_LIMIT)
    return [] if query.blank?

    response = list_users(build_search_payload(query: query, limit: limit))
    response.fetch('result', []).filter_map { |user| normalize_user(user) }
  end

  def find_by_id(user_id:)
    response = list_users(build_find_by_id_payload(user_id: user_id))
    normalize_user(response.fetch('result', []).first)
  end

  private

  def build_search_payload(query:, limit:)
    {
      'query' => {
        'offset' => 0,
        'limit' => limit,
        'asc' => true
      },
      'sortingColumn' => 'USER_FIELD_NAME_FIRST_NAME',
      'queries' => search_queries(query)
    }
  end

  def build_find_by_id_payload(user_id:)
    {
      'query' => {
        'offset' => 0,
        'limit' => 1,
        'asc' => true
      },
      'queries' => [
        {
          'inUserIdsQuery' => {
            'userIds' => [user_id]
          }
        }
      ]
    }
  end

  def text_query(field, query)
    {
      field => query,
      'method' => TEXT_QUERY_METHOD
    }
  end

  def search_queries(query)
    [
      {
        'typeQuery' => { 'type' => 'TYPE_HUMAN' }
      },
      {
        'orQuery' => {
          'queries' => text_search_queries(query)
        }
      }
    ]
  end

  def text_search_queries(query)
    [
      { 'firstNameQuery' => text_query('firstName', query) },
      { 'lastNameQuery' => text_query('lastName', query) },
      { 'userNameQuery' => text_query('userName', query) },
      { 'emailQuery' => text_query('emailAddress', query) }
    ]
  end

  def list_users(payload)
    request = build_request(payload)
    response = execute_request(request)
    raise HttpError, "status #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise RequestError, "invalid JSON response (#{e.message})"
  end

  def build_request(payload)
    request = Net::HTTP::Post.new(LIST_USERS_URI)
    request['Authorization'] = "Bearer #{@access_token}"
    request.content_type = 'application/json'
    request.body = payload.to_json
    request
  end

  def execute_request(request)
    Net::HTTP.start(
      LIST_USERS_URI.hostname,
      LIST_USERS_URI.port,
      use_ssl: true,
      open_timeout: HTTP_OPEN_TIMEOUT_SECONDS,
      read_timeout: HTTP_READ_TIMEOUT_SECONDS
    ) do |http|
      http.request(request)
    end
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    raise TimeoutError, "timeout (#{e.message})"
  rescue StandardError => e
    raise RequestError, "request failed (#{e.message})"
  end

  def normalize_user(raw_user)
    return nil if raw_user.blank?

    normalized_user = {
      oidc_id: raw_user['userId'],
      firstname: profile_for(raw_user)['givenName'],
      lastname: profile_for(raw_user)['familyName'],
      email: email_for(raw_user),
      username: raw_user['username']
    }
    return nil if normalized_user.values.any?(&:blank?)

    normalized_user
  end

  def profile_for(raw_user)
    raw_user.dig('human', 'profile') || raw_user['profile'] || {}
  end

  def email_for(raw_user)
    raw_user.dig('human', 'email', 'email').presence ||
      raw_user.dig('profile', 'email').presence ||
      raw_user['email']
  end
end
