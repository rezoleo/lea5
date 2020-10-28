# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:foobar)
  end

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

  test 'should redirect if user is valid' do
    post users_url(format: :html), params: {
      user: {
        firstname: 'patrick',
        lastname: 'bar',
        email: 'patrick@bar.com',
        room: 'E124'
      }
    }
    user = User.find_by(email: 'patrick@bar.com')
    assert_redirected_to user

    post users_url(format: :json), params: {
      user: {
        firstname: 'patrick',
        lastname: 'bar',
        email: 'patrickbar@bar.com',
        room: 'E125'
      }
    }

    user = @response.parsed_body

    assert_template('show')
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

  test 'should redirect if updates are valid' do
    patch user_url(@user, format: :html), params: {
      user: {
        firstname: 'toto',
        lastname: 'titi',
        email: 'toto@titi.tu',
        room: 'B231'
      }
    }
    assert_redirected_to @user

    patch user_url(@user, format: :json), params: {
      user: {
        firstname: 'toto',
        lastname: 'titi',
        email: 'tototiti@titi.tu',
        room: 'B231'
      }
    }
    assert_template 'show'
    user = @response.parsed_body

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

  test 'should destroy a user' do
    assert_difference 'User.count', -1 do
      delete user_path @user
    end
    assert_redirected_to users_url
  end
end
