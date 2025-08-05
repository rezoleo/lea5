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
      @response_body = response.parsed_body
      assert_equal @machine.id, @response_body[:id]
      assert_equal @machine.name, @response_body[:name]
      assert_equal @machine.mac, @response_body[:mac]
      assert_equal @machine.user_id, @response_body[:user][:id]
      assert_equal @machine.ip.ip.to_s, @response_body[:ip]
      assert_equal api_machine_url(@machine), @response_body[:url]
    end

    test 'should not be able to read machine if api key is wrong' do
      get api_machine_url(@machine), headers: { 'Authorization' => 'Bearer wrong_key' }
      assert_response(:unauthorized)
    end

    test 'should be able to read machines index with api key' do
      get api_machines_path, headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :success
      assert_equal Machine.count, response.parsed_body.size
    end

    test 'should not be able to read machines index if api key is wrong' do
      get api_machines_path, headers: { 'Authorization' => 'Bearer wrong_key' }
      assert_response(:unauthorized)
    end

    test 'should be able to query machines by mac address with api key' do
      get api_machines_path(mac: @machine.mac), headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :success
      response_body = response.parsed_body
      assert_equal 1, response_body.size
      assert_equal @machine.mac, response_body.first[:mac]
    end

    test 'should not be able to query machines by mac address if api key is wrong' do
      get api_machines_path(mac: @machine.mac), headers: { 'Authorization' => 'Bearer wrong_key' }
      assert_response(:unauthorized)
    end

    test 'should be able to create a machine with api key' do
      user = users(:ironman)
      post api_machines_path, params: { user_id: user.id, machine: { mac: '00:11:22:33:44:55', name: 'New Machine' } },
                              headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :created
      response_body = response.parsed_body
      assert_equal '00:11:22:33:44:55', response_body[:mac]
      assert_equal 'New Machine', response_body[:name]
      assert_equal user.id, response_body[:user_id]
    end

    test 'should not be able to create a machine if api key is wrong' do
      user = users(:ironman)
      post api_machines_path, params: { user_id: user.id, machine: { mac: '00:11:22:33:44:55', name: 'New Machine' } },
                              headers: { 'Authorization' => 'Bearer wrong_key' }
      assert_response(:unauthorized)
    end

    test 'should not create machine with invalid params' do
      user = users(:ironman)
      post api_machines_path, params: { user_id: user.id, machine: { name: 'No Mac' } },
                              headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :unprocessable_entity
    end
  end
end
