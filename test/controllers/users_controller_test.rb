# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    @user = users(:pepper)

    @admin = users(:ironman)
    sign_in_as @admin, ['rezoleo']
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
end
