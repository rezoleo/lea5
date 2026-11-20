# frozen_string_literal: true

require 'test_helper'

class FreeAccessesControllerUserRightTest < ActionDispatch::IntegrationTest
  def setup
    super
    @user = users(:pepper)
    @admin = users(:ironman)
    sign_in_as @user
  end

  test 'non-admin user should not see free_access creation page' do
    get new_user_free_access_path @user
    assert_response :forbidden
  end

  test 'non-admin user should not create a new free_access' do
    post user_free_accesses_url @user, params: { free_access: { reason: '' } }
    assert_response :forbidden
  end

  test 'non-admin user should not delete a free_access' do
    delete free_access_url @user.free_accesses.first
    assert_response :forbidden
  end

  test 'non-admin user should not be able to update a free_access' do
    patch free_access_url(@user.free_accesses.first), params: { free_access: { reason: '' } }
    assert_response :forbidden
  end
end
