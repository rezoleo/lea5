# frozen_string_literal: true

require 'test_helper'

class SyncAccountsJobTest < ActiveJob::TestCase
  setup do
    Rails.application.credentials.sso_lea5_pat = 'abc'
  end

  test 'updates users, ignores invalid ones and deactivates those missing from the SSO' do
    stub_list_users([ZITADEL_USER_OK, ZITADEL_USER_BAD_EMAIL])

    assert_no_difference 'User.count' do
      SyncAccountsJob.perform_now
    end

    assert_equal 'Tony Jr', users(:ironman).reload.firstname
    assert_equal 'peterp@univ.edu', User.find_by(oidc_id: '326906230427557669').email # invalid email not applied
    assert_nil User.find_by(email: 'pepper@potts.com').oidc_id
  end

  test 'fetches every page of SSO users' do
    first = stub_list_users([ZITADEL_USER_OK], offset: 0, total: 501)
    second = stub_list_users([ZITADEL_USER_BAD_EMAIL], offset: 500, total: 501)

    SyncAccountsJob.perform_now

    assert_requested first
    assert_requested second
  end

  test 'does not deactivate anyone when the SSO fails' do
    stub_request(:post, 'https://sso.rezoleo.fr/v2/users').to_return(status: 500)

    assert_no_changes -> { User.where.not(oidc_id: nil).count } do
      assert_raises(SsoHttpClient::HttpError) { SyncAccountsJob.perform_now }
    end
  end

  test 'users with an incomplete SSO profile are left untouched' do
    stub_list_users([ZITADEL_USER_OK.merge(profile: { givenName: 'Tony' })])

    assert_no_changes -> { users(:ironman).reload.attributes } do
      SyncAccountsJob.perform_now
    end
  end

  test 'users already in sync are not logged as updated' do
    stub_list_users([ZITADEL_USER_OK.merge(profile: ZITADEL_USER_OK[:profile].merge(givenName: 'Tony'))])
    output = StringIO.new
    old_logger = Rails.logger
    Rails.logger = ActiveSupport::Logger.new(output)

    begin
      SyncAccountsJob.perform_now
    ensure
      Rails.logger = old_logger
    end

    assert_not_includes output.string, 'Updated ironman'
  end

  test 'a user that fails validation keeps its oidc_id when missing from the SSO' do
    stub_list_users([])
    pepper = users(:pepper)
    pepper.update_column(:email, 'invalid') # rubocop:disable Rails/SkipsModelValidations

    SyncAccountsJob.perform_now

    assert_equal '923403309843419676', pepper.reload.oidc_id
  end

  ZITADEL_USER_OK = {
    userId: '340191509840366893',
    username: 'ironman',
    profile: { givenName: 'Tony Jr', familyName: 'Stark', email: 'tony@avengers.com' }
  }.freeze
  ZITADEL_USER_BAD_EMAIL = {
    userId: '326906230427557669',
    username: 'peter-parker',
    profile: { givenName: 'Peter', familyName: 'Parker', email: 'peterp@univ@' }
  }.freeze

  private

  def stub_list_users(result, offset: 0, total: result.size)
    stub_request(:post, 'https://sso.rezoleo.fr/v2/users')
      .with(
        headers: { Authorization: 'Bearer abc' },
        body: { query: { offset: offset, limit: 500, asc: true } }.to_json
      )
      .to_return(status: 200, body: { result: result, details: { totalResult: total } }.to_json)
  end
end
