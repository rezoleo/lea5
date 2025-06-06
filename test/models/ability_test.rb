# frozen_string_literal: true

require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  def setup
    super
    @user = users(:pepper)
    @user_ability = UserAbility.new(@user)
    @user_machine = @user.machines.first
    @user_subscription = @user.subscriptions.first
    @user_free_access = @user.free_accesses.first

    @admin = users(:ironman)
    @admin.groups = ['rezoleo'] # runtime value, cannot be set in fixture
    @admin_ability = UserAbility.new(@admin)
    @admin_machine = @admin.machines.first
    @admin_subscription = @admin.subscriptions.first
    @admin_free_access = @admin.free_accesses.first

    @api_key = api_keys(:FakeRadius)
    @api_key_ability = ApiKeyAbility.new(@api_key)
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

  test 'user can read their machines' do
    assert @user_ability.can?(:read, @user_machine)
  end

  test 'user can create a new machine to themselves if place left' do
    assert @user_ability.can?(:create, @user_machine)
  end

  test 'user cannot create a new machine to themselves if no place left' do
    # Override to be configuration independent
    old_value = Object.const_get(:USER_MACHINES_LIMIT)
    silence_warnings do
      Object.const_set(:USER_MACHINES_LIMIT, 0)
    end
    assert @user_ability.cannot?(:create, @user_machine)
  ensure
    silence_warnings do
      Object.const_set(:USER_MACHINES_LIMIT, old_value)
    end
  end

  test 'user can edit their machines' do
    assert @user_ability.can?(:update, @user_machine)
  end

  test 'user can delete their machines' do
    assert @user_ability.can?(:destroy, @user_machine)
  end

  test 'user cannot interact with other users machines' do
    assert @user_ability.cannot?(:create, @admin_machine)
    assert @user_ability.cannot?(:edit, @admin_machine)
    assert @user_ability.cannot?(:destroy, @admin_machine)
  end

  test 'user can read their subscription' do
    assert @user_ability.can?(:read, @user_subscription)
    assert @user_ability.cannot?(:read, @admin_subscription)
  end

  test 'user cannot create a new subscription to themselves' do
    assert @user_ability.cannot?(:create, @user_subscription)
  end

  test 'user cannot edit their subscription' do
    assert @user_ability.cannot?(:edit, @user_subscription)
  end

  test 'user cannot delete their subscription' do
    assert @user_ability.cannot?(:destroy, @user_subscription)
  end

  test 'user can read their free_access' do
    assert @user_ability.can?(:read, @user_free_access)
    assert @user_ability.cannot?(:read, @admin_free_access)
  end

  test 'user cannot create a new free_access to themselves' do
    assert @user_ability.cannot?(:create, @user_free_access)
  end

  test 'user cannot edit their free_access' do
    assert @user_ability.cannot?(:edit, @user_free_access)
  end

  test 'user cannot delete their free_access' do
    assert @user_ability.cannot?(:destroy, @user_free_access)
  end

  test 'admin can do everything' do
    assert @admin_ability.can?(:manage, :all)
  end

  test 'shoul be able to read everything with an api key' do
    assert @api_key_ability.can?(:read, :all)
  end
end
