# frozen_string_literal: true

require 'test_helper'

class ApiKeysControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get api_keys_index_url
    assert_response :success
  end

  test 'should get show' do
    get api_keys_show_url
    assert_response :success
  end

  test 'should get new' do
    get api_keys_new_url
    assert_response :success
  end

  test 'should get create' do
    get api_keys_create_url
    assert_response :success
  end

  test 'should get delete' do
    get api_keys_delete_url
    assert_response :success
  end
end
