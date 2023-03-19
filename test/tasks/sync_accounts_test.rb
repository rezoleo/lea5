# frozen_string_literal: true

require 'json'
require 'rake'
require 'webmock'

class SyncAccountsTest < ActiveSupport::TestCase
  # https://blog.10pines.com/2019/01/14/testing-rake-tasks/
  # https://thoughtbot.com/blog/test-rake-tasks-like-a-boss
  def setup
    Rake.application.rake_require 'tasks/sync_accounts'
    Rake::Task.define_task(:environment)
    Rails.application.credentials.sso_id = '123456'
    Rails.application.credentials.sso_secret = 'super-secret'
  end

  test 'sync_accounts rake task' do
    KeycloakStub.stub_access_token
    KeycloakStub.stub_list_users

    assert_not_equal 'A113', User.find_by(email: 'tony@avengers.com').room

    assert_difference 'User.count', -1 do
      Rake::Task['lea5:sync_accounts'].invoke
    end
    assert_equal 'A113', User.find_by(email: 'tony@avengers.com').room
  end
end

class KeycloakStub
  MOCK_KEYCLOAK_USER_OK = {
    id: '12345678-1234-1234-1234-123456789abc',
    username: 'user1',
    firstName: 'Tony',
    lastName: 'Stark',
    email: 'tony@avengers.com',
    attributes: { locale: ['en'], room: ['A113'] }
  }.freeze
  MOCK_KEYCLOAK_USER_BAD_ROOM = {
    id: '12345678-1234-1234-1234-123456789ghi',
    username: 'user2',
    firstName: 'Peter',
    lastName: 'Parker',
    email: 'peterp@univ.edu',
    attributes: { room: ['BAD-ROOM'] }
  }.freeze

  def self.stub_access_token
    WebMock.stub_request(:post, 'https://auth.rezoleo.fr/realms/rezoleo/protocol/openid-connect/token')
           .with(
             body: WebMock.hash_including({
                                            client_id: '123456',
                                            client_secret: 'super-secret',
                                            grant_type: 'client_credentials'
                                          })
           )
           .to_return(status: 200,
                      body: JSON.dump({ access_token: 'my_access_token' }),
                      headers: { content_type: 'application/json' })
  end

  def self.stub_list_users
    WebMock.stub_request(:get, 'https://auth.rezoleo.fr/admin/realms/rezoleo/users?max=9999')
           .with(headers: { Authorization: 'Bearer my_access_token' })
           .to_return(status: 200,
                      body: JSON.dump([MOCK_KEYCLOAK_USER_OK, MOCK_KEYCLOAK_USER_BAD_ROOM]),
                      headers: {})
  end
end
