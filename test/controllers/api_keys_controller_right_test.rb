# frozen_string_literal: true

require 'test_helper'

class ApiKeysControllerApiKeyRight < ActionDispatch::IntegrationTest
  def setup
    @bearer = api_keys(:FakeRadius)
    @real_key = '5fcdb374f0a70e9ff0675a0ce4acbdf6d21225fe74483319c2766074732d6d80'
  end

  test 'api key bearers should be able to read api keys index' do
    get '/api/api_keys.json', headers: { 'Authorization' => "Bearer #{@real_key}" }
    result = @response.body
    json = JSON(result)
    assert_not_empty json
  end

  test 'should not be able to read api keys index if api key is wrong' do
    get 'api/api_keys.json', headers: { 'Authorization' => "Bearer #{@real_key}x" }
  end
end
