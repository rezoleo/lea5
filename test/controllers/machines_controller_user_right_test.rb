# frozen_string_literal: true

require 'test_helper'

class MachinesControllerUserRightTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:pepper)
    @admin = users(:ironman)
    sign_in_as @user
  end

  test 'non-admin user should not see someone else machine in show' do
    assert_raises CanCan::AccessDenied do
      get machine_path @admin.machines.first
    end
  end

  test 'non-admin user should not see someone else machine in new' do
    assert_raises CanCan::AccessDenied do
      get new_user_machine_path @admin
    end
  end

  test 'non-admin user should not see someone else machine in edit' do
    assert_raises CanCan::AccessDenied do
      get edit_machine_path @admin.machines.first
    end
  end

  test 'non-admin user should not be able to add to someone else a machine' do
    assert_raises CanCan::AccessDenied do
      post user_machines_url(@admin), params: { machine: { name: '' } }
    end
  end

  test 'non-admin user should not be able to update someone else machine' do
    assert_raises CanCan::AccessDenied do
      patch machine_url(@admin.machines.first), params: { machine: { name: '' } }
    end
  end

  test 'non-admin user should not be able to destroy someone else machine' do
    assert_raises CanCan::AccessDenied do
      delete machine_url(@admin.machines.first)
    end
  end
end
