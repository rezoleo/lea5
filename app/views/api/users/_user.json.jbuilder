# frozen_string_literal: true

# locals: (json:, user:)

json.extract! user, :username, :firstname, :lastname, :email, :created_at, :updated_at
json.room user.room&.number
json.url api_user_url(user)
json.internet_access user.internet_access?
