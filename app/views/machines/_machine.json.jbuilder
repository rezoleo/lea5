# frozen_string_literal: true

json.extract! machine, :id, :name, :mac, :ip, :user
json.url machine_url(machine, format: :json)
