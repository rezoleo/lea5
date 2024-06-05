# frozen_string_literal: true

require 'test_helper'

class ApiKeysControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:pepper)

    @admin = users(:ironman)
    sign_in_as @admin, ['rezoleo']
  end

  test 'should get show' do
    get '/api_keys/show'
    assert_response :success
  end

  test 'should get new' do
    get new_api_key_path
    assert_response :success
  end

  test 'should create api key and redirect if machine is valid in html' do
    assert_difference 'ApiKey.count', 1 do
      post api_keys_url(format: :html), params: {
        api_key: {
          bearer_name: 'ultron'
        }
      }
    end
  end
end
