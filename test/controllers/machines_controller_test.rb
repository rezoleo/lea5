# frozen_string_literal: true

require 'test_helper'

class MachinesControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    @machine = machines(:jarvis)
    @owner = @machine.user
    sign_in_as @owner
  end

  test 'should get new' do
    get new_user_machine_path(@owner)
    assert_template 'machines/new'
  end

  test 'should create a machine and redirect if machine is valid in html' do
    assert_difference 'Machine.count', 1 do
      post user_machines_url(@owner, format: :html), params: {
        machine: {
          name: 'ultron',
          mac: '66:66:66:66:66:66'
        }
      }
    end

    assert_redirected_to @owner
  end

  test 'should add an ip on create' do
    post user_machines_url(@owner), params: {
      machine: {
        name: 'ultron',
        mac: '66:66:66:66:66:66'
      }
    }
    machine = Machine.find_by(mac: '66:66:66:66:66:66')
    assert_not_nil machine.ip
  end

  test 'should re-render new if machine is invalid with html' do
    post user_machines_url(@owner), params: { machine: { name: 'No mac' } }
    assert_template 'machines/new'
  end

  test 'should render edit' do
    get edit_machine_url(@machine)
    assert_template 'machines/edit'
  end

  test 'should redirect if updates are valid in html' do
    patch machine_url(@machine), params: {
      machine: {
        name: 'Jarvis',
        mac: '33:33:33:33:33:33'
      }
    }
    assert_redirected_to @owner
  end

  test 'should re-render edit if updates are invalid with html' do
    patch machine_url(@machine), params: { machine: { name: '' } }
    assert_template 'machines/edit'
  end

  test 'should destroy a machine and redirect to owner in html' do
    assert_difference 'Machine.count', -1 do
      delete machine_url(@machine)
    end
    assert_redirected_to user_url(@owner)
  end
end
