# frozen_string_literal: true

require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:ironman)
    @machine = machines(:jarvis)
    @ip = ips(:ip1)

    sign_in_as @admin, ['rezoleo']
  end

  test 'should work with empty query' do
    get search_path
    assert_response :success
  end

  test 'should return nothing for non matching users' do
    non_matching_users = ['Nymous', 'Nymou', 'Laurent', 'Gadac']

    non_matching_users.each do |user|
      get search_path, params: { q: user }
      assert_response :success
      assert_no_match 'Results among users:', @response.body, "should return nothing for #{user} (user not in DB)"
    end
  end

  test 'should return nothing for non matching mac' do
    non_matching_macs = ['DE:1A:B3:17:95:B9', 'DC:1A:B3:17:95:B9']

    non_matching_macs.each do |mac|
      get search_path, params: { q: mac }
      assert_response :success
      assert_no_match 'Results among machines:', @response.body, "should return nothing for #{mac} (mac not in DB)"
    end
  end

  test 'should return nothing for non matching ips' do
    invalid_ips = ['300.255', 'not.an.ip']

    invalid_ips.each do |query|
      get search_path, params: { q: query }
      assert_response :success
      assert_no_match 'Results among machines:', @response.body, "should not return result for #{query}"
    end
  end

  # TODO: test unicity of result
  test 'should return a unique machine for matching ips' do
    valid_ips = ['172.130.0.0']

    valid_ips.each do |query|
      get search_path, params: { q: query }
      assert_response :success
      assert_match 'Results among machines:', @response.body, "should return something for #{query}"
    end
  end
end
