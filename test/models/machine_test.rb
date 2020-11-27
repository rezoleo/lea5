# frozen_string_literal: true

require 'test_helper'

class MachineTest < ActiveSupport::TestCase
  def setup
    @user = users(:ironman)
    @machine = @user.machines.new(name: 'Machine-1',
                                  mac: 'AD:12:A8:F6:45:BD')
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

  test "mac can't be empty" do
    @machine.mac = '     '
    assert_not @machine.valid?
  end

  test 'mac should be unique' do
    duplicate_machine = @machine.dup
    @machine.save
    assert_not duplicate_machine.valid?
  end

  test 'mac must be of a valid format' do
    valid_macs = %w[AD:14:D4:87:4B:D7 ba:d4:8a:54:47:3f 23:Eb:1a:3A:BC:f7
                    AD-14-D4-87-4B-D7 ba-d4-8a-54-47-3f AD14D4874BD7 bad48a54473f]

    invalid_macs = ['AD:14', # must not be too short
                    'AD:14:D4:87:4B:', # trailing colon
                    'AD:14:D4:87:4B:45:DE', # must not be too long
                    'AG:14:D4:87:4B:D7', # must be hexadecimal
                    'AD/14/D4/87/4B/D7',
                    'AD:143:D4:87:4B:D', # must be 6 times XX
                    'AD:14-D4:87:4B:D7', # must follow one format
                    'AD:14D4:87:4B:D7']
    valid_macs.each do |valid_mac|
      @machine.mac = valid_mac
      assert @machine.valid?, "#{valid_mac.inspect} should be valid"
    end

    invalid_macs.each do |invalid_mac|
      @machine.mac = invalid_mac
      assert_not @machine.valid?, "#{invalid_mac.inspect} should be invalid"
    end
  end

  test 'machines should be destroyed when the user is destroyed' do
    @machine.save
    assert_difference 'Machine.count', -1 do
      @user.destroy
    end
  end
end
