# frozen_string_literal: true

require 'test_helper'

class ApiMachinesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @bearer = api_keys(:FakeRadius)
    @real_key = '5fcdb374f0a70e9ff0675a0ce4acbdf6d21225fe74483319c2766074732d6d80'

    @machine = machines(:jarvis)
  end

  test 'api key bearers should be able to read machine' do
    get "#{api_machine_url(@machine)}.json", headers: { 'Authorization' => "Bearer #{@real_key}" }
    assert_response :success
    @response = response.parsed_body
    assert_equal @machine.id, @response[:id]
    assert_equal @machine.name, @response[:name]
    assert_equal @machine.mac, @response[:mac]
    assert_equal @machine.user_id, @response[:user][:id]
  end

  test 'should not be able to read machine if api key is wrong' do
    assert ActiveRecord::RecordNotFound do
      get "#{api_machine_url(@machine)}.json", headers: { 'Authorization' => "Bearer #{@real_key}x" }
    end
  end
end
