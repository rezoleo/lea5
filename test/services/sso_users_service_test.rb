# frozen_string_literal: true

require 'test_helper'

class SsoUsersServiceTest < ActiveSupport::TestCase
  def setup
    super
    @service = SsoUsersService.new(access_token: 'abc')
  end

  test 'search returns empty array for blank query' do
    assert_empty @service.search(query: '')
  end

  test 'search normalizes human payloads' do
    stub_users_response([sso_user(
      '1',
      username: 'ironman',
      human_profile: { 'givenName' => 'Tony', 'familyName' => 'Stark' },
      human_email: { 'email' => 'tony.stark@avengers.com' }
    )])

    assert_equal [
      {
        oidc_id: '1',
        firstname: 'Tony',
        lastname: 'Stark',
        email: 'tony.stark@avengers.com',
        username: 'ironman'
      }
    ], @service.search(query: 'tony')
  end

  test 'search normalizes profile payloads and skips invalid users' do
    stub_users_response([
      sso_user('2',
               username: 'pepper',
               profile: { 'givenName' => 'Pepper', 'familyName' => 'Potts', 'email' => 'pepper@potts.com' }),
      sso_user('4',
               username: 'hulk',
               human_profile: { 'givenName' => 'Bruce', 'familyName' => '' },
               human_email: { 'email' => 'bruce.banner@avengers.com' }),
      nil
    ])

    assert_equal [
      {
        oidc_id: '2',
        firstname: 'Pepper',
        lastname: 'Potts',
        email: 'pepper@potts.com',
        username: 'pepper'
      }
    ], @service.search(query: 'tony')
  end

  test 'search normalizes top-level email fallback payloads' do
    stub_users_response([sso_user(
      '3',
      username: 'spiderman',
      profile: { 'givenName' => 'Peter', 'familyName' => 'Parker' },
      email: 'peter.parker@avengers.com'
    )])

    assert_equal [
      {
        oidc_id: '3',
        firstname: 'Peter',
        lastname: 'Parker',
        email: 'peter.parker@avengers.com',
        username: 'spiderman'
      }
    ], @service.search(query: 'tony')
  end

  test 'find_by_id returns a normalized user' do
    stub_users_response([sso_user(
      '99',
      username: 'ironman',
      human_profile: { 'givenName' => 'Tony', 'familyName' => 'Stark' },
      human_email: { 'email' => 'tony@avengers.com' }
    )])

    assert_equal({
                   oidc_id: '99',
                   firstname: 'Tony',
                   lastname: 'Stark',
                   email: 'tony@avengers.com',
                   username: 'ironman'
                 }, @service.find_by_id(user_id: '99'))
  end

  test 'search raises HttpError on non-success response' do
    stub_users_http_response(500, 'Internal Server Error')

    assert_raises(SsoHttpClient::HttpError) do
      @service.search(query: 'tony')
    end
  end

  test 'find_by_id raises TimeoutError on timeout' do
    WebMock.stub_request(:post, "#{SsoHttpClient::SSO_BASE_URI}/v2/users")
           .to_raise(Net::ReadTimeout.new)

    assert_raises(SsoHttpClient::TimeoutError) do
      @service.find_by_id(user_id: '123')
    end
  end

  test 'search raises RequestError on invalid JSON response' do
    stub_users_http_response(200, 'not json')

    assert_raises(SsoHttpClient::RequestError) do
      @service.search(query: 'tony')
    end
  end

  private

  def stub_users_response(users)
    stub_users_http_response(200, JSON.dump({ result: users }))
  end

  def stub_users_http_response(status, body)
    WebMock.stub_request(:post, "#{SsoHttpClient::SSO_BASE_URI}/v2/users")
           .to_return(status:, body:)
  end

  def sso_user(id, username:, **attributes)
    user = { 'userId' => id, 'username' => username }

    if attributes[:human_profile] || attributes[:human_email]
      user['human'] = {
        'profile' => attributes[:human_profile],
        'email' => attributes[:human_email]
      }.compact
    end

    user['profile'] = attributes[:profile] if attributes[:profile]
    user['email'] = attributes[:email] if attributes[:email]

    user
  end
end
