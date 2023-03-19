# frozen_string_literal: true

require 'net/http'
require 'json'

namespace :lea5 do
  desc 'sync accounts from SSO'
  task sync_accounts: [:environment] do
    sso_users = retrieve_users_from_sso

    User.all.each do |user|
      user_from_sso = sso_users[user.keycloak_id]
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
  uri = URI('https://auth.rezoleo.fr/realms/rezoleo/protocol/openid-connect/token')
  params = {
    client_id: Rails.application.credentials.sso_id!,
    client_secret: Rails.application.credentials.sso_secret!,
    grant_type: 'client_credentials'
  }
  res = Net::HTTP.post_form(uri, params)
  # Needs "view-users" service account role in Keycloak
  access_token = JSON.parse(res.body)['access_token']

  uri = URI('https://auth.rezoleo.fr/admin/realms/rezoleo/users?max=9999') # because pagination is a no no for keycloak
  res = Net::HTTP.get_response(uri, { 'Authorization' => "Bearer #{access_token}" })
  JSON.parse(res.body).index_by { |user| user['id'] }
end

def update_user(user, user_from_sso)
  user.update_from_sso(
    firstname: user_from_sso['firstName'],
    lastname: user_from_sso['lastName'],
    email: user_from_sso['email'],
    room: user_from_sso['attributes']['room'].first
  )
  if user.save
    puts "Updated #{user.email}"
  else
    puts "Error updating user #{user.email}"
  end
end

def destroy_user(user)
  if user.destroy
    puts "Destroyed #{user.email}"
  else
    puts "Error destroying user #{user.email}"
  end
end
