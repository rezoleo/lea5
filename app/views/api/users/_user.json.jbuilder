# frozen_string_literal: true

# locals: (json:, user:)

json.extract! user, :id, :firstname, :lastname, :username, :email, :room, :created_at, :updated_at
json.url api_user_url(user)
json.internet_expiration user.internet_expiration
