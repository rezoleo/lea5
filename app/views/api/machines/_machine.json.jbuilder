# frozen_string_literal: true

# locals: (json:, machine:)

json.extract! machine, :mac, :name, :created_at, :updated_at
json.username machine.user.username
json.ip machine.ip.ip.to_s
json.url api_machine_url(machine.mac)
json.internet_access machine.user.internet_access?
