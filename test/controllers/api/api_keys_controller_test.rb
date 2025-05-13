# frozen_string_literal: true

require 'test_helper'

module Api
  class ApiApiKeysControllerTest < ActionDispatch::IntegrationTest
    def setup
      @original_key = 'Lea5_zUN4wsViWcg3UBLCMhCtqgQt'
    end

    test 'api key bearers should be able to read api keys index' do
      get api_api_keys_path, headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :success
      assert_equal ApiKey.count, response.parsed_body.size
    end

    test 'should not be able to read api keys index if api key is wrong' do
      get api_api_keys_path, headers: { 'Authorization' => 'Bearer wrongkey' }
      assert_response(:unauthorized)
    end
  end
end
