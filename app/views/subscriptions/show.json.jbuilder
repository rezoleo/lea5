# frozen_string_literal: true

json.partial! 'subscriptions/subscription', subscription: @subscription
json.user @subscription.user, partial: 'users/user', as: :user
