# frozen_string_literal: true

require 'test_helper'

module Api
  class ApiMachinesControllerTest < ActionDispatch::IntegrationTest
    def setup
      @original_key = 'Lea5_zUN4wsViWcg3UBLCMhCtqgQt'
      @machine = machines(:jarvis)
    end

    test 'should be able to read machine with api key' do
      get api_machine_url(@machine), headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :success
      @response = response.parsed_body
      assert_equal @machine.id, @response[:id]
      assert_equal @machine.name, @response[:name]
      assert_equal @machine.mac, @response[:mac]
      assert_equal @machine.user_id, @response[:user][:id]
    end

    test 'should not be able to read machine if api key is wrong' do
      get api_machine_url(@machine), headers: { 'Authorization' => 'Bearer wrong_key' }
      assert_response(:unauthorized)
    end
  end
end
