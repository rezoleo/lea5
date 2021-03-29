# frozen_string_literal: true

json.extract! subscription, :id, :duration, :price, :cancelled, :cancelled_date, :created_at, :updated_at
# json.url subscription_url(subscription, format: :json)
