# frozen_string_literal: true

# locals: (json:, user:)

json.extract! user, :id, :firstname, :lastname, :username, :email, :created_at, :updated_at
json.room user.room&.number
json.url api_user_url(user)
json.internet_expiration user.internet_expiration
