# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    OmniAuth.config.add_mock(:oidc, { provider: 'oidc',
                                      uid: '111111111111111111',
                                      info: { first_name: 'John',
                                              last_name: 'Doe',
                                              email: 'john@doe.com' },
                                      extra: { raw_info: { preferred_username: 'john-doe' } } })
  end

  test 'should create a new user if does not exist' do
    assert_difference 'User.count', 1 do
      get auth_callback_path
    end
  end

  test 'should find user if already exists' do
    User.create(firstname: 'John', lastname: 'Doe', email: 'john@doe.com', username: 'john-doe',
                oidc_id: '111111111111111111')

    assert_difference 'User.count', 0 do
      get auth_callback_path
    end
  end

  test 'should redirect to user profile' do
    get auth_callback_path

    assert_redirected_to profile_path
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

  test 'logout after an SSO login also logs out of the SSO' do
    Rails.application.credentials.sso_id = 'lea5'
    sign_in_as users(:pepper)
    delete logout_path

    assert_redirected_to "#{SSO_LOGOUT_URL}?client_id=lea5&post_logout_redirect_uri=#{CGI.escape(root_url)}"
    assert_not_predicate self, :logged_in?
  ensure
    Rails.application.credentials.sso_id = nil
  end

  test 'logout stays local when no SSO client is configured' do
    sign_in_as users(:pepper)
    delete logout_path

    assert_redirected_to root_path
  end

  test 'a failed SSO login redirects to root with the reason' do
    get auth_failure_path, params: { message: 'access_denied' }

    assert_redirected_to root_path
    assert_equal 'Login failed: Access denied', flash[:error]
  end

  test 'a deleted user is logged out instead of crashing' do
    user = User.create!(firstname: 'No', lastname: 'Sales', email: 'no@sales.com', username: 'no-sales', oidc_id: '42')
    sign_in_as user
    user.destroy!

    get root_path

    assert_response :success
    assert_not_predicate self, :logged_in?
  end

  test 'an anonymous user is sent to log in' do
    get user_path(users(:ironman))

    assert_redirected_to root_path
    assert_equal 'Please log in to access this page.', flash[:error]
  end
end
