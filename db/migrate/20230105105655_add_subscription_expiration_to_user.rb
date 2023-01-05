# frozen_string_literal: true

class AddSubscriptionExpirationToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :subscription_expiration, :datetime
  end
end
