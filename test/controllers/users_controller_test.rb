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
    assert_equal 'ironman-sso', created_user.username
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

  test 'should handle SSO request error in new_from_sso' do
    WebMock.stub_request(:post, SSO_URL).to_raise(SsoHttpClient::RequestError.new)

    get new_from_sso_users_path, params: { query: 'tony' }

    assert_response :unprocessable_entity
    assert_template 'users/new_from_sso'
    assert_match 'SSO request failed', @response.body
  end

  test 'should handle SSO request error in create_from_sso' do
    WebMock.stub_request(:post, SSO_URL).to_raise(SsoHttpClient::RequestError.new)

    post create_from_sso_users_path, params: { oidc_id: '123', room_number: 'B231', query: 'tony' }

    assert_response :unprocessable_entity
    assert_template 'users/new_from_sso'
    assert_match 'SSO request failed', @response.body
  end

  test 'should re-render sso page if user build from SSO is invalid' do
    oidc_id = '100000000000000001'
    stub_find_user_by_id_request(oidc_id: oidc_id)

    @user.update!(username: 'ironman-sso')

    assert_no_difference 'User.count' do
      post create_from_sso_users_path, params: { oidc_id: oidc_id, room_number: 'B231', query: 'tony' }
    end

    assert_response :unprocessable_entity
    assert_template 'users/new_from_sso'
    assert_match 'Username has already been taken', @response.body
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

  test 'should only update the room' do
    patch user_url(@user, format: :html), params: {
      user: { firstname: 'toto', room_number: 'B231' }
    }
    assert_redirected_to @user
    @user.reload
    assert_equal 'B231', @user.room.number
    assert_not_equal 'toto', @user.firstname
  end

  test 'should not move a user to an occupied room without confirmation' do
    patch user_path @user, params: { user: { room_number: @admin.room.number } }
    assert_template 'users/edit'
    assert_equal @admin, @admin.room.reload.user
  end

  test 'should move a user to an occupied room and unassign the previous occupant' do
    room = @admin.room
    patch user_path @user, params: { user: { room_number: room.number, room_override: '1' } }
    assert_redirected_to @user
    assert_equal @user, room.reload.user
    assert_nil @admin.reload.room
  end

  test 'should create a user in an occupied room with confirmation' do
    room = @admin.room
    post users_path, params: {
      user: { firstname: 'a', lastname: 'b', email: 'a@b.com', username: 'a-b',
              room_number: room.number, room_override: '1' }
    }
    assert_equal 'a@b.com', room.reload.user.email
    assert_nil @admin.reload.room
  end

  test 'should destroy a user and redirect to users in html' do
    assert_difference 'User.count', -1 do
      delete user_url(@user, format: :html)
    end
    assert_redirected_to users_url
  end

  test 'should paginate index' do
    limit = Pagy::OPTIONS[:limit]
    # Two full pages plus a partial one, whatever the configured limit is.
    create_extra_users((limit * 2) + 1 - User.count)

    get users_path
    assert_dom '.user', count: limit
    assert_dom '.pagination'

    get users_path, params: { page: 2 }
    assert_dom '.user', count: limit

    get users_path, params: { page: 3 }
    assert_dom '.user', count: 1
  end

  test 'should not paginate index when results fit on a single page' do
    User.where.not(id: @admin.id).find_each(&:destroy)

    get users_path
    assert_dom '.user', count: 1
    assert_dom '.pagination', count: 0
  end

  test 'should render an empty page for an out of range page number' do
    get users_path, params: { page: 9999 }
    assert_response :success
    assert_dom '.user', count: 0
  end

  test 'should not repeat users across pages' do
    create_extra_users(Pagy::OPTIONS[:limit] * 2)

    get users_path
    first_page = css_select('.user').map(&:to_s)
    get users_path, params: { page: 2 }
    second_page = css_select('.user').map(&:to_s)

    assert_empty first_page & second_page
  end

  private

  def create_extra_users(count)
    count.times do |i|
      User.create!(
        firstname: "Extra#{i}",
        lastname: format('Paginated%03d', i),
        email: "extra#{i}@paginated.com",
        username: "extra-#{i}",
        wifi_password: 'password'
      )
    end
  end

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
      username: 'ironman-sso',
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
