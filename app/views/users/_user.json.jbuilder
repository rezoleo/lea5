# frozen_string_literal: true

json.extract! user, :id, :firstname, :lastname, :date_end_subscription, :email, :room, :created_at, :updated_at
json.url user_url(user, format: :json)
