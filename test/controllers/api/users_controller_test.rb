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
      @response_body = response.parsed_body
      assert_equal @user.id, @response_body[:id]
      assert_equal @user.firstname, @response_body[:firstname]
      assert_equal @user.lastname, @response_body[:lastname]
      assert_equal @user.email, @response_body[:email]
      assert_equal @user.room, @response_body[:room]
      assert_equal api_user_url(@user), @response_body[:url]
      assert_equal @user.internet_expiration, @response_body[:internet_expiration]
      openssl_legacy_provider = OpenSSL::Provider.load('legacy')
      assert_equal OpenSSL::Digest::MD4.hexdigest(@user.wifi_password.encode('utf-16le')),
                   @response_body[:ntlm_password]
      openssl_legacy_provider.unload
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
