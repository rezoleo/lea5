# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  SSO_URL = 'https://sso.rezoleo.fr/v2/users'

  def setup
    super
    @user = users(:pepper)

    @admin = users(:ironman)
    sign_in_as @admin, ['rezoleo']
    Rails.application.credentials.sso_lea5_pat = 'abc'
  end

  # TODO: when another template index has been made, try to render it and test assert_template 'index'
  #   to see if it only check a template index or check that it is the users' index template
  test 'should get index' do
    get users_path
    assert_template 'users/index'
  end

  test 'should get show' do
    get user_path @user
    assert_template 'users/show'
    assert_match @user.email, @response.body
    assert_match @user.room.number, @response.body
  end

  test 'should get new' do
    get new_user_path
    assert_template 'users/new'
  end

  test 'should get new_from_sso' do
    get new_from_sso_users_path
    assert_template 'users/new_from_sso'
  end

  test 'should search users in sso from new_from_sso' do
    stub_search_users_request(query: 'tony')

    get new_from_sso_users_path, params: { query: 'tony' }

    assert_response :success
    assert_match 'Tony Stark', @response.body
  end

  test 'should create a user from sso and redirect' do
    oidc_id = '100000000000000001'
    stub_find_user_by_id_request(oidc_id: oidc_id)

    assert_difference 'User.count', 1 do
      post create_from_sso_users_path, params: { oidc_id: oidc_id, room_number: 'B231', query: 'tony' }
    end

    created_user = User.find_by(oidc_id: oidc_id)
    assert_not_nil created_user
    assert_equal 'Tony', created_user.firstname
    assert_equal 'Stark', created_user.lastname
    assert_equal 'tony.stark@avengers.com', created_user.email
    assert_equal 'ironman.sso', created_user.username
    assert_equal 'B231', created_user.room.number
    assert_redirected_to created_user
  end

  test 'should re-render sso page if selected sso user does not exist anymore' do
    stub_find_user_by_id_request(oidc_id: '999999999999999999', result: [])

    post create_from_sso_users_path, params: { oidc_id: '999999999999999999', room_number: 'B231', query: 'tony' }

    assert_response :unprocessable_entity
    assert_template 'users/new_from_sso'
    assert_match 'could not be found', @response.body
  end

  test 'should create a user and redirect if user is valid in html' do
    assert_difference 'User.count', 1 do
      post users_url(format: :html), params: {
        user: {
          firstname: 'patrick',
          lastname: 'bar',
          email: 'patrick@bar.com',
          username: 'patrick-bar',
          room_number: 'E124'
        }
      }
    end
    user = User.find_by(email: 'patrick@bar.com')
    assert_redirected_to user
    assert_equal 'E124', user.room.number
  end

  test 'should re-render new if user is invalid with html' do
    post users_path, params: { user: { firstname: 'Empty' } }
    assert_template 'users/new'
  end

  test 'should render edit' do
    get edit_user_path @user
    assert_template 'users/edit'
  end

  test 'should redirect if updates are valid in html' do
    patch user_url(@user, format: :html), params: {
      user: {
        firstname: 'toto',
        lastname: 'titi',
        email: 'toto@titi.tu',
        username: 'toto-titi',
        room_number: 'B231'
      }
    }
    assert_redirected_to @user.reload
    assert_equal 'B231', @user.room.number
  end

  test 'should re-render edit if updates are invalid with html' do
    patch user_path @user, params: { user: { firstname: '' } }
    assert_template 'users/edit'
  end

  test 'should destroy a user and redirect to users in html' do
    assert_difference 'User.count', -1 do
      delete user_url(@user, format: :html)
    end
    assert_redirected_to users_url
  end

  private

  def stub_search_users_request(query:)
    WebMock.stub_request(:post, SSO_URL)
           .with(headers: { Authorization: 'Bearer abc', 'Content-Type' => 'application/json' }) do |request|
      search_request_matches?(request:, query:)
    end
           .to_return(
             status: 200,
             body: JSON.dump(search_result_body),
             headers: { content_type: 'application/json' }
           )
  end

  def stub_find_user_by_id_request(oidc_id:, result: nil)
    users = result || [default_sso_user(oidc_id: oidc_id)]

    WebMock.stub_request(:post, SSO_URL)
           .with(headers: { Authorization: 'Bearer abc', 'Content-Type' => 'application/json' }) do |request|
      find_by_id_request_matches?(request:, oidc_id:)
    end
           .to_return(
             status: 200,
             body: JSON.dump({ result: users, details: { totalResult: users.size } }),
             headers: { content_type: 'application/json' }
           )
  end

  def search_request_matches?(request:, query:)
    body = JSON.parse(request.body)
    search_or_query = body.dig('queries', 1, 'orQuery', 'queries') || []
    search_values = search_or_query.map { |search_query| search_query.values.first.values.first }

    body.dig('query', 'limit') == 25 &&
      body['sortingColumn'] == 'USER_FIELD_NAME_FIRST_NAME' &&
      search_values.include?(query)
  end

  def find_by_id_request_matches?(request:, oidc_id:)
    body = JSON.parse(request.body)
    body.dig('queries', 0, 'inUserIdsQuery', 'userIds') == [oidc_id]
  end

  def default_sso_user(oidc_id:)
    {
      userId: oidc_id,
      username: 'ironman.sso',
      human: {
        profile: {
          givenName: 'Tony',
          familyName: 'Stark'
        },
        email: {
          email: 'tony.stark@avengers.com'
        }
      }
    }
  end

  def search_result_body
    {
      result: [default_sso_user(oidc_id: '100000000000000001')],
      details: { totalResult: 1 }
    }
  end
end
