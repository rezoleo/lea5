# frozen_string_literal: true

# locals: (json:, user:)

json.extract! user, :id, :firstname, :lastname, :email, :room, :created_at, :updated_at, :wifi_password
json.url user_url(user, format: :json)
