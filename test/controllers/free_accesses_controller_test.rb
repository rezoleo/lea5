# frozen_string_literal: true

require 'test_helper'

class FreeAccessesControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    @free_access = free_accesses(:one)
    @owner = @free_access.user
    sign_in_as @owner, ['rezoleo']
  end

  test 'should get new' do
    get new_user_free_access_path @owner
    assert_template 'free_accesses/new'
  end

  test 'should create a free_accesses and redirect if free_accesses is valid' do
    assert_difference 'FreeAccess.count', 1 do
      post user_free_accesses_url @owner, params: {
        free_access: {
          start_at: Time.current,
          end_at: 3.months.from_now,
          reason: 'Good dog'
        }
      }
    end

    assert_redirected_to @owner
  end

  test 'should re-render new if free_access is invalid' do
    post user_free_accesses_url(@owner), params: {
      free_access: {
        start_at: 3.months.from_now,
        end_at: Time.current,
        reason: 'Bad cop'
      }
    }
    assert_template 'free_accesses/new'
  end

  test 'should render edit' do
    get edit_free_access_url(@free_access)
    assert_template 'free_accesses/edit'
  end

  test 'should redirect if updates are valid' do
    patch free_access_url(@free_access), params: {
      free_access: {
        start_at: Time.current,
        end_at: 3.months.from_now,
        reason: 'Good boy'
      }
    }
    assert_redirected_to @owner
  end

  test 'should re-render edit if updates are invalid' do
    patch free_access_url(@free_access), params: { free_access: { reason: '' } }
    assert_template 'free_accesses/edit'
  end

  test 'should destroy a free_access and redirect to owner' do
    assert_difference 'FreeAccess.count', -1 do
      delete free_access_url(@free_access)
    end
    assert_redirected_to user_url(@owner)
  end
end
