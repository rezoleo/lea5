# frozen_string_literal: true

require 'test_helper'

class ApiApiKeysControllerTest < ActionDispatch::IntegrationTest
  def setup
    @bearer = api_keys(:FakeRadius)
    @real_key = Rails.application.credentials.generated_key!
  end

  test 'api key bearers should be able to read api keys index' do
    get "#{api_api_keys_path}.json", headers: { 'Authorization' => "Bearer #{@real_key}" }
    assert_response :success
    assert_equal ApiKey.count, response.parsed_body.size
  end

  test 'should not be able to read api keys index if api key is wrong' do
    assert ActiveRecord::RecordNotFound do
      get "#{api_api_keys_path}.json", headers: { 'Authorization' => "Bearer #{@real_key}x" }
    end
  end
end
