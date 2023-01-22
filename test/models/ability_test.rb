# frozen_string_literal: true

require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  def setup
    @user = users(:pepper)
    @user_ability = Ability.new(@user)
    @admin = users(:ironman)
    @admin_ability = Ability.new(@admin)
  end

  test 'user can read themselves' do
    assert @user_ability.can?(:read, @user)
  end

  test 'user can update themselves' do
    assert @user_ability.can?(:update, @user)
  end

  test 'user cannot destroy themselves' do
    assert @user_ability.cannot?(:destroy, @user)
  end

  test 'user cannot create a new user' do
    assert @user_ability.cannot?(:create, @user)
  end

  test 'admin can do everything' do
    assert @admin_ability.can?(:manage, :all)
  end
end
