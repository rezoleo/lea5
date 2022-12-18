# frozen_string_literal: true

require 'net/http'
require 'json'

desc 'sync accounts from sso'
task sync_accounts: [:environment] do
  users_from_sso = retrieve_users_from_sso
  users_from_sso.each do |user|
    puts user['username']
  end
end

def retrieve_users_from_sso
  uri = URI('http://localhost:8080/realms/rezoleo/protocol/openid-connect/token')
  params = { client_id: 'test', client_secret: 'N98HJEKTO6ox6KZTZLXFMtRmCSbh32kh',
             grant_type: 'client_credentials' }
  res = Net::HTTP.post_form(uri, params)
  access_token = JSON.parse(res.body)['access_token']

  uri = URI('http://localhost:8080/admin/realms/rezoleo/users?max=9999') # because pagination is a no no for keycloak
  res = Net::HTTP.get_response(uri, { 'Authorization' => "Bearer #{access_token}" })
  JSON.parse(res.body)
end

#
# usersFromSSO = getUsersFromSSO()
# users = User.all
#
# users.each |user| do
#   if userFromSSO = usersFromSSO.find(u -> u.keycloak_id == user.keycloak_id)
#     user.update(userFromSSO)
#   else
#     user.delete()
#   end
# end
#
