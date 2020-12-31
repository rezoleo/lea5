# frozen_string_literal: true

require 'test_helper'

class IpTest < ActiveSupport::TestCase
  def setup
    @machine = machines(:jarvis)
    @ip = @machine.build_ip(ip: '172.30.48.245')
  end

  test 'ip should be valid' do
    assert @ip.valid?
  end

  test "ip can't be nil" do
    @ip.ip = nil
    assert_not @ip.valid?
  end

  test "ip can't be empty" do
    @ip.ip = '   '
    assert_not @ip.valid?
  end

  test 'ip should be unique' do
    dup_ip = Ip.new(ip: '172.30.48.245')
    @ip.save
    assert_not dup_ip.valid?
  end

  test 'ip must be of a valid format' do
    valid_ips = %w[172.30.110.68]
    invalid_ips = %w[172..30.110.68 172.300.110.68 172.0004.110.68 172.30.68 172.30.110.68.17 172.30.110.68.]

    valid_ips.each do |valid_ip|
      @ip.ip = valid_ip
      assert @ip.valid?, "#{valid_ip} should be valid"
    end

    invalid_ips.each do |invalid_ip|
      @ip.ip = invalid_ip
      assert_not @ip.valid?, "#{invalid_ip} should be invalid"
    end
  end
end
