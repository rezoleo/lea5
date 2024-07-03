# frozen_string_literal: true

require 'test_helper'

class UsersControllerUserRight < ActionDispatch::IntegrationTest
  def setup
    @user = users(:pepper)
    @admin = users(:ironman)
    sign_in_as @user
  end

  test 'non-admin user should see only themselves in index' do
    assert_operator User.count, :>, 1

    get users_path
    assert_select 'a.user', count: 1
    assert_select 'li', text: Regexp.new(@user.room)
  end

  test 'non-admin user should not see someone else in show' do
    assert_raises CanCan::AccessDenied do
      get user_path @admin
    end
  end

  test 'non-admin user should not see someone else in edit' do
    assert_raises CanCan::AccessDenied do
      get edit_user_path @admin
    end
  end
  test 'non-admin user should not see user creation page' do
    assert_raises CanCan::AccessDenied do
      get new_user_path
    end
  end

  test 'non-admin user should not create a new user' do
    assert_raises CanCan::AccessDenied do
      post users_path, params: { user: { firstname: '' } }
    end
  end

  test 'non-admin user should not update someone else' do
    assert_raises CanCan::AccessDenied do
      patch user_path @admin, params: { user: { firstname: '' } }
    end
  end

  test 'non-admin user should not destroy themselves' do
    assert_raises CanCan::AccessDenied do
      delete user_path @user
    end
  end

  test 'non-admin cannot access api keys' do
    assert_raises CanCan::AccessDenied do
      get api_keys_path
    end
  end
end
