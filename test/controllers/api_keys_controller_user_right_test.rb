# frozen_string_literal: true

require 'test_helper'

class ApiKeysControllerUserRightTest < ActionDispatch::IntegrationTest
  def setup
    @api_key = api_keys(:FakeRadius)

    @user = users(:pepper)
    sign_in_as @user
  end

  test 'non-admin user should not create a new api key' do
    post api_keys_path, params: { api_key: { name: '' } }
    assert_response :forbidden
  end

  test 'non-admin user should not see api key creation page' do
    get new_api_key_path
    assert_response :forbidden
  end

  test 'non-admin user should not be able to destroy an api key' do
    delete api_key_url(@api_key)
    assert_response :forbidden
  end
end
