# frozen_string_literal: true

require 'test_helper'

class UsersControllerUserRight < ActionDispatch::IntegrationTest
  def setup
    super
    @user = users(:pepper)
    @admin = users(:ironman)
    sign_in_as @user
  end

  test 'non-admin user should see only themselves in index' do
    assert_operator User.count, :>, 1

    get users_path
    assert_select 'a.user', count: 1
  end

  test 'non-admin user should not see someone else in show' do
    get user_path @admin
    assert_response :forbidden
  end

  test 'non-admin user should not edit themselves' do
    get edit_user_path @user
    assert_response :forbidden
  end

  test 'non-admin user should not update themselves' do
    patch user_path @user, params: { user: { room_number: 'B231' } }
    assert_response :forbidden
  end

  test 'non-admin user should not see someone else in edit' do
    get edit_user_path @admin
    assert_response :forbidden
  end

  test 'non-admin user should not see user creation page' do
    get new_user_path
    assert_response :forbidden
  end

  test 'non-admin user should not create a new user' do
    post users_path, params: { user: { firstname: '' } }
    assert_response :forbidden
  end

  test 'non-admin user should not update someone else' do
    patch user_path @admin, params: { user: { firstname: '' } }
    assert_response :forbidden
  end

  test 'non-admin user should not destroy themselves' do
    delete user_path @user
    assert_response :forbidden
  end
end
