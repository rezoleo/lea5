# frozen_string_literal: true

# locals: (json:, machine:)

json.extract! machine, :id, :name, :mac, :created_at, :updated_at
json.ip machine.ip.ip.to_s
json.url api_machine_url(machine)
