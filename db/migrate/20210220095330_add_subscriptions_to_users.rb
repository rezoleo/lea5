# frozen_string_literal: true

class AddSubscriptionsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :subscriptions, :user, foreign_key: true, null: false # rubocop:disable Rails/NotNullColumn
  end
end
