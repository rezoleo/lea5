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
end
