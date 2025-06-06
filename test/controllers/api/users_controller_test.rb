# frozen_string_literal: true

require 'test_helper'

module Api
  class ApiUsersControllerTest < ActionDispatch::IntegrationTest
    def setup
      @original_key = 'Lea5_zUN4wsViWcg3UBLCMhCtqgQt'
      @user = users(:ironman)
    end

    test 'should be able to read user with api key' do
      get api_user_path(@user), headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :success
      @response = response.parsed_body
      assert_equal @user.id, @response[:id]
      assert_equal @user.firstname, @response[:firstname]
      assert_equal @user.lastname, @response[:lastname]
      assert_equal @user.email, @response[:email]
      assert_equal @user.room, @response[:room]
    end

    test 'should be able to read users index with api key' do
      get api_users_path, headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :success
      assert_equal User.count, response.parsed_body.size
    end

    test 'should not be able to read user if api key is wrong' do
      get api_user_path(@user), headers: { 'Authorization' => 'Bearer wrong_key' }
      assert_response(:unauthorized)
    end

    test 'should not be able to read users index if api key is wrong' do
      get api_users_path, headers: { 'Authorization' => 'Bearer wrong_key' }
      assert_response(:unauthorized)
    end
  end
end
