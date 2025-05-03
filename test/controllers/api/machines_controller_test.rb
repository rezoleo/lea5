# frozen_string_literal: true

require 'test_helper'

module Api
  class ApiMachinesControllerTest < ActionDispatch::IntegrationTest
    def setup
      @bearer = api_keys(:FakeRadius)
      @real_key = Rails.application.credentials.generated_key!

      @machine = machines(:jarvis)
    end

    test 'api key bearers should be able to read machine' do
      get api_machine_url(@machine), headers: { 'Authorization' => "Bearer #{@real_key}" }
      assert_response :success
      @response = response.parsed_body
      assert_equal @machine.id, @response[:id]
      assert_equal @machine.name, @response[:name]
      assert_equal @machine.mac, @response[:mac]
      assert_equal @machine.user_id, @response[:user][:id]
    end

    test 'should not be able to read machine if api key is wrong' do
      get api_machine_url(@machine), headers: { 'Authorization' => "Bearer #{@real_key}x" }
      assert_response(:unauthorized)
    end
  end
end
