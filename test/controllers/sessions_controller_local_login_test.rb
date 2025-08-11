# frozen_string_literal: true

require 'test_helper'

class SessionsControllerLocalLoginTest < ActionDispatch::IntegrationTest
  def setup
    super
    OmniAuth.config.add_mock(:developer, { provider: 'developer',
                                           uid: 'john@doe.com',
                                           info: { first_name: 'John',
                                                   last_name: 'Doe',
                                                   email: 'john@doe.com',
                                                   room: 'F123',
                                                   groups: 'rezoleo' } })
  end

  test 'should create a new user if does not exist' do
    assert_difference 'User.count', 1 do
      get auth_callback_developer_path
    end
  end

  test 'should find user if already exists' do
    User.create(firstname: 'John', lastname: 'Doe', email: 'john@doe.com', room: 'F123')

    assert_difference 'User.count', 0 do
      get auth_callback_developer_path
    end
  end

  test 'should redirect to user profile' do
    get auth_callback_developer_path

    assert_redirected_to user_path User.find_by(email: 'john@doe.com').id
  end

  test 'should create a session with current_user' do
    get auth_callback_developer_path

    assert_predicate self, :logged_in?
    assert_equal User.find_by(email: 'john@doe.com').id, current_user.id
  end

  test 'logout should redirect to root' do
    delete logout_path

    assert_redirected_to root_path
  end
end
