# frozen_string_literal: true

require 'test_helper'

module Api
  class ApiMachinesControllerTest < ActionDispatch::IntegrationTest
    def setup
      @original_key = 'Lea5_zUN4wsViWcg3UBLCMhCtqgQt'
      @machine = machines(:jarvis)
      @machine2 = machines(:ultron)
    end

    test 'should be able to read machine with api key' do
      get api_machine_url(@machine.mac), headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :success
      response_body = response.parsed_body
      assert_not response_body.key?(:id)
      assert_equal @machine.name, response_body[:name]
      assert_equal @machine.mac, response_body[:mac]
      assert_equal @machine.ip.ip.to_s, response_body[:ip]
      assert_equal api_machine_url(@machine.mac), response_body[:url]
      assert_equal @machine.user.internet_access?, response_body[:internet_access]
    end

    test 'should not be able to read machine if api key is wrong' do
      get api_machine_url(@machine.mac), headers: { 'Authorization' => 'Bearer wrong_key' }
      assert_response(:unauthorized)
    end

    test 'should not be able to read machine if api key is missing' do
      get api_machine_url(@machine.mac)
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

    test 'should not be able to read machines index if api key is missing' do
      get api_machines_path
      assert_response(:unauthorized)
    end

    test 'should be able to read machines with internet access with api key' do
      get api_machines_path, headers: { 'Authorization' => "Bearer #{@original_key}" },
                             params: { with_internet_access: '1' }
      assert_response :success
      response_body = response.parsed_body
      assert_equal 1, response_body.size
    end

    test 'should accept any mac address format' do
      get api_machine_url(@machine.mac.delete(':')), headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :success
      assert_equal @machine.mac, response.parsed_body[:mac]
    end

    test 'should return not found for unknown mac address with api key' do
      get api_machine_url('DE:1A:B3:17:95:FF'), headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :not_found
    end

    test 'should return bad request for invalid mac address with api key' do
      get api_machine_url('invalid_mac'), headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :bad_request
    end

    test 'should not read a machine by id' do
      get "/api/machines/#{@machine.id}", headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :bad_request
    end

    test 'should be able to create a machine with api key' do
      user = users(:ironman)
      post api_machines_path, params: { username: user.username,
                                        machine: { mac: '00-11-22-AA-BB-CC', name: 'New Machine' } },
                              headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :created
      response_body = response.parsed_body
      assert_not response_body.key?(:id)
      assert_equal '00:11:22:aa:bb:cc', response_body[:mac]
      assert_equal 'New Machine', response_body[:name]
      assert_equal user.username, response_body[:username]
    end

    test 'should not be able to create a machine if api key is wrong' do
      user = users(:ironman)
      post api_machines_path, params: { username: user.username,
                                        machine: { mac: '00:11:22:33:44:55', name: 'New Machine' } },
                              headers: { 'Authorization' => 'Bearer wrong_key' }
      assert_response(:unauthorized)
    end

    test 'should not be able to create a machine if api key is missing' do
      user = users(:ironman)
      post api_machines_path, params: { username: user.username,
                                        machine: { mac: '00:11:22:33:44:55', name: 'New Machine' } }
      assert_response(:unauthorized)
    end

    test 'should not create machine with invalid params' do
      user = users(:ironman)
      post api_machines_path, params: { username: user.username, machine: { name: 'No Mac' } },
                              headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :unprocessable_entity
    end

    test 'should be able to create a machine if it is in the limit with api key' do
      # Override to be configuration independent
      old_value = Object.const_get(:USER_MACHINES_LIMIT)
      silence_warnings do
        Object.const_set(:USER_MACHINES_LIMIT, 1)
      end
      user = @machine.user
      user.machines.destroy_all

      machine = { name: 'ultron', mac: '66:66:66:66:66:66' }
      assert_difference 'Machine.count', 1 do
        post api_machines_url, params: { username: user.username, machine: machine },
                               headers: { 'Authorization' => "Bearer #{@original_key}" }
      end
    ensure
      silence_warnings do
        Object.const_set(:USER_MACHINES_LIMIT, old_value)
      end
    end

    test 'should not be able to create a machine if limit already reached with api key' do
      # Override to be configuration independent
      old_value = Object.const_get(:USER_MACHINES_LIMIT)
      silence_warnings do
        Object.const_set(:USER_MACHINES_LIMIT, 0)
      end
      user = @machine.user
      user.machines.destroy_all
      machine = { name: 'ultron', mac: '66:66:66:66:66:66' }

      post api_machines_url, params: { username: user.username, machine: machine },
                             headers: { 'Authorization' => "Bearer #{@original_key}" }

      assert_response :forbidden
    ensure
      silence_warnings do
        Object.const_set(:USER_MACHINES_LIMIT, old_value)
      end
    end

    test 'should not paginate machines index when neither page nor limit is given' do
      get api_machines_path, headers: { 'Authorization' => "Bearer #{@original_key}" }
      assert_response :success
      assert_equal Machine.count, response.parsed_body.size
      assert_nil response.headers['current-page']
    end

    test 'should paginate machines index when limit is given' do
      get api_machines_path, headers: { 'Authorization' => "Bearer #{@original_key}" }, params: { limit: 2 }
      assert_response :success
      assert_equal 2, response.parsed_body.size
      assert_equal Machine.count.to_s, response.headers['total-count']
    end

    test 'should filter on internet access before paginating' do
      get api_machines_path, headers: { 'Authorization' => "Bearer #{@original_key}" },
                             params: { with_internet_access: '1', limit: 10 }
      assert_response :success
      assert_equal 1, response.parsed_body.size
      assert_equal '1', response.headers['total-count']
      assert_equal @machine2.mac, response.parsed_body.first[:mac]
    end

    test 'should count only matching machines when filtering and paginating' do
      get api_machines_path, headers: { 'Authorization' => "Bearer #{@original_key}" },
                             params: { with_internet_access: '1', limit: 1, page: 1 }
      assert_response :success
      assert_equal [@machine2.mac], response.parsed_body.pluck(:mac)
      assert_equal '1', response.headers['total-pages']
    end

    test 'should keep with_internet_access in the link header' do
      get api_machines_path, headers: { 'Authorization' => "Bearer #{@original_key}" },
                             params: { with_internet_access: '1', limit: 1 }

      assert_match(/with_internet_access=1/, response.headers['link'])
    end

    test 'should not filter when with_internet_access is 0' do
      get api_machines_path, headers: { 'Authorization' => "Bearer #{@original_key}" },
                             params: { with_internet_access: '0' }
      assert_response :success
      assert_equal Machine.count, response.parsed_body.size
    end
  end
end
