# frozen_string_literal: true

require 'test_helper'

class ApiKeysControllerUserRightTest < ActionDispatch::IntegrationTest
  def setup
    @bearer = api_keys(:FakeRadius)

    @user = users(:pepper)
    sign_in_as @user
  end

  test 'non-admin should not be able to see api keys' do
    assert_raises CanCan::AccessDenied do
      get api_keys_path
    end
  end

  test 'non-admin user should not create a new api key' do
    assert_raises CanCan::AccessDenied do
      post api_keys_path, params: { api_key: { bearer_name: '' } }
    end
  end

  test 'non-admin user should not see api key creation page' do
    assert_raises CanCan::AccessDenied do
      get new_api_key_path
    end
  end

  test 'non-admin user should not be able to destroy an api key' do
    assert_raises CanCan::AccessDenied do
      delete api_key_url(@bearer)
    end
  end
end
