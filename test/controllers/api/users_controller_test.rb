# frozen_string_literal: true

require 'test_helper'

module Api
  class ApiUsersControllerTest < ActionDispatch::IntegrationTest
    def setup
      @original_key = 'Lea5_zUN4wsViWcg3UBLCMhCtqgQt'
      @user = users(:ironman)
      @user_with_dot = users(:spiderman)
    end

    test 'should be able to read user with api key' do
      get api_user_path(@user), headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :success
      response_body = response.parsed_body
      assert_equal @user.id, response_body[:id]
      assert_equal @user.firstname, response_body[:firstname]
      assert_equal @user.lastname, response_body[:lastname]
      assert_equal @user.email, response_body[:email]
      assert_equal @user.room&.number, response_body[:room]
      assert_equal api_user_url(@user), response_body[:url]
      assert_equal @user.internet_expiration, response_body[:internet_expiration]
      openssl_legacy_provider = OpenSSL::Provider.load('legacy')
      assert_equal OpenSSL::Digest::MD4.hexdigest(@user.wifi_password.encode('utf-16le')),
                   response_body[:ntlm_password]
      openssl_legacy_provider.unload
    end

    test 'should be able to read users index with api key' do
      get api_users_path, headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :success
      assert_equal User.count, response.parsed_body.size
    end

    test 'should not be able to read users index if api key is wrong' do
      get api_users_path, headers: { 'Authorization' => 'Bearer wrong_key' }
      assert_response(:unauthorized)
    end

    test 'should not be able to read users index if api key is missing' do
      get api_users_path
      assert_response(:unauthorized)
    end

    test 'should not be able to read user if api key is wrong' do
      get api_user_path(@user), headers: { 'Authorization' => 'Bearer wrong_key' }
      assert_response(:unauthorized)
    end

    test 'should not be able to read user if api key is missing' do
      get api_user_path(@user)
      assert_response(:unauthorized)
    end

    test 'should be able to query user by username with api key' do
      get api_user_path(@user.username), headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :success
    end

    test 'should be able to query user by username with api key even if username contains a dot' do
      get api_user_path(@user_with_dot.username), headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :success
    end

    test 'should not paginate users index when neither page nor limit is given' do
      get api_users_path, headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :success
      assert_equal User.count, response.parsed_body.size
      assert_nil response.headers['current-page']
      assert_nil response.headers['link']
    end

    test 'should paginate users index when limit is given' do
      get api_users_path, headers: { 'Authorization' => "Bearer #{@original_key}" }, params: { limit: 2 }
      assert_response :success
      assert_equal 2, response.parsed_body.size
      assert_equal '1', response.headers['current-page']
      assert_equal '2', response.headers['page-limit']
      assert_equal User.count.to_s, response.headers['total-count']
      assert_equal '2', response.headers['total-pages']
    end

    test 'should paginate users index when only page is given' do
      get api_users_path, headers: { 'Authorization' => "Bearer #{@original_key}" }, params: { page: 1 }
      assert_response :success
      assert_equal [User.count, Pagy::OPTIONS[:limit]].min, response.parsed_body.size
      assert_equal '1', response.headers['current-page']
    end

    test 'should return the remaining users on the last page' do
      get api_users_path, headers: { 'Authorization' => "Bearer #{@original_key}" },
                          params: { limit: 2, page: 2 }
      assert_response :success
      assert_equal User.count - 2, response.parsed_body.size
      assert_equal '2', response.headers['current-page']
    end

    test 'should not repeat users across API pages' do
      get api_users_path, headers: { 'Authorization' => "Bearer #{@original_key}" },
                          params: { limit: 2, page: 1 }
      first_page = response.parsed_body.pluck(:id)
      get api_users_path, headers: { 'Authorization' => "Bearer #{@original_key}" },
                          params: { limit: 2, page: 2 }
      second_page = response.parsed_body.pluck(:id)

      assert_empty first_page & second_page
      assert_equal User.count, (first_page + second_page).uniq.size
    end

    test 'should expose RFC-8288 link headers' do
      get api_users_path, headers: { 'Authorization' => "Bearer #{@original_key}" }, params: { limit: 2 }
      link = response.headers['link']

      assert_match(/rel="first"/, link)
      assert_match(/rel="next"/, link)
      assert_match(/rel="last"/, link)
      assert_no_match(/rel="previous"/, link)
      assert_match(/limit=2/, link)
    end

    test 'should expose a previous link from the second page on' do
      get api_users_path, headers: { 'Authorization' => "Bearer #{@original_key}" },
                          params: { limit: 2, page: 2 }

      assert_match(/rel="previous"/, response.headers['link'])
    end

    test 'should cap a client requested limit to LIMIT_MAX' do
      get api_users_path, headers: { 'Authorization' => "Bearer #{@original_key}" }, params: { limit: 10_000 }
      assert_response :success
      assert_equal ApiApplicationController::LIMIT_MAX.to_s, response.headers['page-limit']
    end

    test 'should return an empty page for an out of range page number' do
      get api_users_path, headers: { 'Authorization' => "Bearer #{@original_key}" }, params: { page: 9999 }
      assert_response :success
      assert_empty response.parsed_body
    end
  end
end
