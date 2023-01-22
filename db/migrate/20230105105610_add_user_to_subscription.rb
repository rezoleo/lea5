# frozen_string_literal: true

class AddUserToSubscription < ActiveRecord::Migration[7.0]
  def change
    add_reference :subscriptions, :user, null: false, foreign_key: true # rubocop:disable Rails/NotNullColumn
  end
end
