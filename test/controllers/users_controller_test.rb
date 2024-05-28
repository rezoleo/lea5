# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
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
    assert_match @user.room, @response.body
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
          room: 'E124'
        }
      }
    end
    user = User.find_by(email: 'patrick@bar.com')
    assert_redirected_to user
  end

  test 'should create a user and send user info if user is valid in json' do
    assert_difference 'User.count', 1 do
      post users_url(format: :json), params: {
        user: {
          firstname: 'patrick',
          lastname: 'bar',
          email: 'patrickbar@bar.com',
          room: 'E125'
        }
      }
    end
    user = @response.parsed_body
    assert_template('users/show')
    assert_response(:created)
    assert_equal 'patrick', user['firstname']
    assert_equal 'bar', user['lastname']
    assert_equal 'patrickbar@bar.com', user['email']
    assert_equal 'E125', user['room']
  end

  test 'should re-render new if user is invalid with html' do
    post users_path, params: { user: { firstname: 'Empty' } }
    assert_template 'users/new'
  end

  test 'should send errors if user is invalid with json' do
    post users_url(format: :json), params: { user: { firstname: 'Empty' } }
    assert_response(:unprocessable_entity)
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
        room: 'B231'
      }
    }
    assert_redirected_to @user
  end

  test 'should redirect if updates are valid in json' do
    patch user_url(@user, format: :json), params: {
      user: {
        firstname: 'toto',
        lastname: 'titi',
        email: 'tototiti@titi.tu',
        room: 'B231'
      }
    }
    assert_template 'users/show'
    user = @response.parsed_body
    assert_response(:ok)
    assert_equal 'toto', user['firstname']
    assert_equal 'titi', user['lastname']
    assert_equal 'tototiti@titi.tu', user['email']
    assert_equal 'B231', user['room']
  end

  test 'should re-render edit if updates are invalid with html' do
    patch user_path @user, params: { user: { firstname: '' } }
    assert_template 'users/edit'
  end

  test 'should send errors if updates are invalid with json' do
    patch user_url(@user, format: :json),
          params: { user: { email: 'Empty' } }
    assert_response(:unprocessable_entity)
  end

  test 'should destroy a user and redirect to users in html' do
    assert_difference 'User.count', -1 do
      delete user_url(@user, format: :html)
    end
    assert_redirected_to users_url
  end

  test 'should destroy a user and send a 204 in json' do
    assert_difference 'User.count', -1 do
      delete user_url(@user, format: :json)
    end
    assert_response :no_content
  end
end
