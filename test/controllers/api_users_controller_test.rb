# frozen_string_literal: true

require 'test_helper'

class ApiUsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @bearer = api_keys(:FakeRadius)
    @real_key = Rails.application.credentials.generated_key!

    @user = users(:ironman)
  end

  test 'api key bearers should be able to read user' do
    get "#{api_user_path(@user)}.json", headers: { 'Authorization' => "Bearer #{@real_key}" }
    assert_response :success
    @response = response.parsed_body
    assert_equal @user.id, @response[:id]
    assert_equal @user.firstname, @response[:firstname]
    assert_equal @user.lastname, @response[:lastname]
    assert_equal @user.email, @response[:email]
    assert_equal @user.room, @response[:room]
  end

  test 'api key bearers should be able to read users index' do
    get "#{api_users_path}.json", headers: { 'Authorization' => "Bearer #{@real_key}" }
    assert_response :success
    assert_equal User.count, response.parsed_body.size
  end

  test 'should not be able to read user if api key is wrong' do
    assert ActiveRecord::RecordNotFound do
      get "#{api_user_path(@user)}.json", headers: { 'Authorization' => "Bearer #{@real_key}x" }
    end
  end

  test 'should not be able to read users index if api key is wrong' do
    assert ActiveRecord::RecordNotFound do
      get "#{api_users_path}.json", headers: { 'Authorization' => "Bearer #{@real_key}x" }
    end
  end
end
