# frozen_string_literal: true

require 'net/http'
require 'json'

namespace :lea5 do
  desc 'sync accounts from SSO'
  task sync_accounts: [:environment] do
    sso_users = retrieve_users_from_sso

    User.find_each do |user|
      user_from_sso = sso_users[user.oidc_id]
      if user_from_sso
        update_user(user, user_from_sso)
      else
        destroy_user(user)
      end
    end
  end
end

# @return [Hash<String, Hash<String, Object>>]
def retrieve_users_from_sso
  access_token = Rails.application.credentials.sso_lea5_pat!
  uri = URI('https://sso.rezoleo.fr/v2/users')
  limit = 500
  offset = 0
  all_users = {}

  loop do
    parsed = fetch_users_page(uri, access_token, offset, limit)
    result = parsed['result'] || []
    total = parsed.dig('details', 'totalResult').to_i

    result.each { |user| all_users[user['userId']] = user }

    offset += limit
    break if offset >= total
  end

  all_users
end

def fetch_users_page(uri, access_token, offset, limit)
  req = Net::HTTP::Post.new(uri)
  req['Authorization'] = "Bearer #{access_token}"
  req['Content-Type'] = 'application/json'
  req.body = { query: { offset: offset, limit: limit, asc: true } }.to_json

  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(req)
  end

  JSON.parse(res.body)
end

def update_user(user, user_from_sso)
  user.update_from_sso(
    firstname: user_from_sso['profile']['givenName'],
    lastname: user_from_sso['profile']['familyName'],
    email: user_from_sso['profile']['email'],
    username: user_from_sso['username']
  )
  if user.save
    puts "Updated #{user.username}"
  else
    puts "Error updating user #{user.username}"
  end
end

def destroy_user(user)
  if user.destroy
    puts "Destroyed #{user.username}"
  else
    # :nocov:
    puts "Error destroying user #{user.username}"
    # :nocov:
  end
end
