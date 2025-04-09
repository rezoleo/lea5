# frozen_string_literal: true

require 'test_helper'

class ApiApiKeysControllerTest < ActionDispatch::IntegrationTest
  def setup
    @bearer = api_keys(:FakeRadius)
    @real_key = Rails.application.credentials.generated_key!
    @machine = machines(:jarvis)
    @admin = users(:ironman)
    sign_in_as @admin
  end

  test 'users should not be able to see api keys through api endpoint' do
    assert_raises CanCan::AccessDenied do
      get "#{api_api_keys_path}.json"
    end
  end

  test 'users should not be able to see users index through api endpoint' do
    assert_raises CanCan::AccessDenied do
      get "#{api_users_path}.json"
    end
  end

  test 'users should not be able to see user through api endpoint' do
    assert_raises CanCan::AccessDenied do
      get "#{api_user_path(@admin)}.json"
    end
  end

  test 'users should not be able to see machine through api endpoint' do
    assert_raises CanCan::AccessDenied do
      get "#{api_machine_url(@machine)}.json"
    end
  end
end
