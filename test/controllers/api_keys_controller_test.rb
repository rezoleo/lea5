# frozen_string_literal: true

require 'test_helper'

class ApiKeysControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:pepper)

    @admin = users(:ironman)
    sign_in_as @admin, ['rezoleo']

    @api_key = api_keys(:FakeRadius)
  end

  test 'should get index' do
    get api_keys_path
    assert_template 'api_keys/index'
  end

  test 'should get new' do
    get new_api_key_path
    assert_response :success
  end

  test 'should create api key and redirect if api key is valid in html' do
    assert_difference 'ApiKey.count', 1 do
      post api_keys_url(format: :html), params: {
        api_key: {
          name: 'Ultron'
        }
      }
    end
  end

  test 'should destroy an api key and redirect to index in html' do
    assert_difference 'ApiKey.count', -1 do
      delete api_key_url(@api_key, format: :html)
    end
    assert_redirected_to api_keys_url
  end

  test 'should re-render new if api key name is invalid' do
    post api_keys_url(format: :html), params: {
      api_key: {
        name: ''
      }
    }
    assert_response :unprocessable_entity
    assert_template 'api_keys/new'
  end
end
