# frozen_string_literal: true

require 'test_helper'

class FreeAccessTest < ActiveSupport::TestCase
  def setup
    super
    @user = users(:ironman)
    @free_access = free_accesses(:one)
  end

  test 'free_access is valid' do
    assert_predicate @free_access, :valid?
  end

  test 'start_at and end_at cannot be nil' do
    @free_access.start_at = nil
    assert_not_predicate @free_access, :valid?

    @free_access.reload

    @free_access.end_at = nil
    assert_not_predicate @free_access, :valid?
  end

  test 'end_date is strictly after start_date' do
    @free_access.end_at = @free_access.start_at - 1.month
    assert_not_predicate @free_access, :valid?

    @free_access.end_at = @free_access.start_at
    assert_not_predicate @free_access, :valid?
  end

  test 'reason cannot be nil nor empty' do
    @free_access.reason = nil
    assert_not_predicate @free_access, :valid?

    @free_access.reason = ''
    assert_not_predicate @free_access, :valid?
  end

  test 'free_access should be destroyed when the user is destroyed' do
    @user.free_accesses.destroy_all
    @user.reload
    @user.free_accesses.create(start_at: Time.current, end_at: 3.months.from_now, reason: 'Good cop')

    assert_difference 'FreeAccess.count', -1 do
      @user.destroy
    end
  end
end
