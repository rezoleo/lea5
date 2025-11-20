# frozen_string_literal: true

require 'json'
require 'rake'
require 'webmock'

class SyncAccountsTest < ActiveSupport::TestCase
  # https://blog.10pines.com/2019/01/14/testing-rake-tasks/
  # https://thoughtbot.com/blog/test-rake-tasks-like-a-boss
  def setup
    super
    Rake.application.rake_require 'tasks/sync_accounts'
    Rake::Task.define_task(:environment)
    Rails.application.credentials.sso_lea5_pat = 'abc'
  end

  test 'sync_accounts rake task' do
    ZitadelStub.stub_list_users

    tony = User.find_by(email: 'tony@avengers.com')
    original_room = tony.room

    assert_difference 'User.count', -1 do
      Rake::Task['lea5:sync_accounts'].invoke
    end

    tony.reload
    assert_equal original_room, tony.room
  end
end

class ZitadelStub
  MOCK_ZITADEL_USER_OK = {
    userId: '340191509840366893',
    state: 'USER_STATE_ACTIVE',
    username: 'ironman',
    profile: {
      givenName: 'Tony',
      familyName: 'Stark',
      email: 'tony@avengers.com'
    }
  }.freeze
  MOCK_ZITADEL_USER_BAD_EMAIL = {
    userId: '326906230427557669',
    state: 'USER_STATE_ACTIVE',
    username: 'peter.parker',
    profile: {
      givenName: 'Peter',
      familyName: 'Parker',
      email: 'peterp@univ'
    }
  }.freeze

  def self.stub_list_users
    WebMock.stub_request(:post, 'https://sso.rezoleo.fr/v2/users')
           .with(
             headers: { Authorization: 'Bearer abc', 'Content-Type' => 'application/json' },
             body: { query: { offset: 0, limit: 500, asc: true } }.to_json
           )
           .to_return(status: 200,
                      body: JSON.dump({ result: [MOCK_ZITADEL_USER_OK, MOCK_ZITADEL_USER_BAD_EMAIL],
                                        details: { totalResult: 2 } }),
                      headers: { content_type: 'application/json' })
  end
end
