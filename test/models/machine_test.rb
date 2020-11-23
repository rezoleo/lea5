# frozen_string_literal: true

require 'test_helper'

class MachineTest < ActiveSupport::TestCase
  def setup
    @machine = Machine.new(name: 'Machine-1',
                           mac: 'AD:12:A8:F6:45')
  end

  test 'machine is valid' do
    assert @machine.valid?
  end

  test "name can't be nil" do
    @machine.name = nil
    assert_not @machine.valid?
  end

  test "name can't be empty" do
    @machine.name = '    '
    assert_not @machine.valid?
  end

  test "mac can't be nil" do
    @machine.mac = nil
    assert_not @machine.valid?
  end

  test "mac can 't be empty" do
    @machine.mac = '     '
    assert_not @machine.valid?
  end
end
