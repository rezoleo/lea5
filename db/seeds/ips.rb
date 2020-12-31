# frozen_string_literal: true

require 'ipaddress'

now = Time.zone.now
ip_range = IPAddress::IPv4.new('172.30.128.0/17')
Ip.insert_all(ip_range.hosts.map { |ip| { ip: ip.to_s, created_at: now, updated_at: now } }) # rubocop:disable Rails/SkipsModelValidations
