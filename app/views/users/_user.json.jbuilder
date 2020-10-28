# frozen_string_literal: true

json.extract! user, :id, :firstname, :lastname, :email, :room, :created_at, :updated_at
json.url user_url(user, format: :json)
