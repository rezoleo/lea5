# frozen_string_literal: true

require 'test_helper'

class MachinesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @machine = machines(:jarvis)
    @owner = @machine.user
  end

  test 'should get index' do
    get user_machines_path(@owner)
    assert_template 'machines/index'
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

  test 'should create a machine and send machine info if machine is valid in json' do
    assert_difference 'Machine.count', 1 do
      post user_machines_url(@owner, format: :json), params: {
        machine: {
          name: 'ultron',
          mac: '66:66:66:66:66:66'
        }
      }
    end
    machine = @response.parsed_body
    assert_template('machines/show')
    assert_response(:created)
    assert_equal 'ultron', machine['name']
    assert_equal '66:66:66:66:66:66', machine['mac']
    assert_equal @owner.id, machine['user']['id']
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

  test 'should show an error and not create a machine if no ip available in html' do
    Ip.destroy_all

    assert_difference 'Machine.count', 0 do
      post user_machines_url(@owner), params: {
        machine: {
          name: 'ultron',
          mac: '66:66:66:66:66:66'
        }
      }
    end
    assert_template 'machines/new'
    assert_select 'li', 'No more IPs available'
  end

  test 'should show an error and not create a machine if no ip available in json' do
    Ip.destroy_all

    assert_difference 'Machine.count', 0 do
      post user_machines_url(@owner, format: :json), params: {
        machine: {
          name: 'ultron',
          mac: '66:66:66:66:66:66'
        }
      }
    end
    machine = @response.parsed_body
    assert_response(:unprocessable_entity)
    assert_equal ['No more IPs available'], machine['base']
  end

  test 'should re-render new if machine is invalid with html' do
    post user_machines_url(@owner), params: { machine: { name: 'No mac' } }
    assert_template 'machines/new'
  end

  test 'should send errors if machine is invalid with json' do
    post user_machines_url(@owner, format: :json), params: { machine: { name: 'No mac' } }
    assert_response(:unprocessable_entity)
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

  test 'should redirect if updates are valid in json' do
    patch machine_url(@machine, format: :json), params: {
      machine: {
        name: 'Jarvis',
        mac: '33:33:33:33:33:33'
      }
    }
    assert_template 'machines/show'
    machine = @response.parsed_body
    assert_response(:ok)
    assert_equal 'Jarvis', machine['name']
    assert_equal '33:33:33:33:33:33', machine['mac']
    assert_equal @owner.id, machine['user']['id']
  end

  test 'should re-render edit if updates are invalid with html' do
    patch machine_url(@machine), params: { machine: { name: '' } }
    assert_template 'machines/edit'
  end

  test 'should send errors if updates are invalid with json' do
    patch machine_url(@machine, format: :json),
          params: { machine: { name: '' } }
    assert_response(:unprocessable_entity)
  end

  test 'should destroy a machine and redirect to owner in html' do
    assert_difference 'Machine.count', -1 do
      delete machine_url(@machine)
    end
    assert_redirected_to user_url(@owner)
  end

  test 'should destroy a machine and send a 204 in json' do
    assert_difference 'Machine.count', -1 do
      delete machine_url(@machine, format: :json)
    end
    assert_response 204
  end
end
