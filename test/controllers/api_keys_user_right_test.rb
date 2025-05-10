# frozen_string_literal: true

require 'test_helper'

class ApiKeysUserRightTest < ActionDispatch::IntegrationTest
  def setup
    @machine = machines(:jarvis)
    @admin = users(:ironman)
    sign_in_as @admin
  end

  test 'users should not be able to see api keys through api endpoint' do
    get api_api_keys_path
    assert_response(:unauthorized)
  end

  test 'users should not be able to see users index through api endpoint' do
    get api_users_path
    assert_response(:unauthorized)
  end

  test 'users should not be able to see user through api endpoint' do
    get api_user_path(@admin)
    assert_response(:unauthorized)
  end

  test 'users should not be able to see machine through api endpoint' do
    get api_machine_url(@machine)
    assert_response(:unauthorized)
  end
end
