# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @api_key = api_keys(:FakeRadius)
    @real_key = '5fcdb374f0a70e9ff0675a0ce4acbdf6d21225fe74483319c2766074732d6d80'

    OmniAuth.config.add_mock(:keycloak, { provider: 'keycloak',
                                          uid: '11111111-1111-1111-1111-111111111111',
                                          info: { first_name: 'John',
                                                  last_name: 'Doe',
                                                  email: 'john@doe.com' },
                                          extra: { raw_info: { room: 'F123' } } })
  end

  test 'should create a new user if does not exist' do
    assert_difference 'User.count', 1 do
      get auth_callback_path
    end
  end

  test 'should find user if already exists' do
    User.create(firstname: 'Jonh', lastname: 'Doe', email: 'john@doe.com', room: 'F123',
                keycloak_id: '11111111-1111-1111-1111-111111111111')

    assert_difference 'User.count', 0 do
      get auth_callback_path
    end
  end

  test 'should redirect to user profile' do
    get auth_callback_path

    assert_redirected_to user_path User.find_by(email: 'john@doe.com').id
  end

  test 'should create a session with current_user' do
    get auth_callback_path

    assert_predicate self, :logged_in?
    assert_equal User.find_by(email: 'john@doe.com').id, current_user.id
  end

  test 'logout should redirect to root' do
    delete logout_path

    assert_redirected_to root_path
  end
end
