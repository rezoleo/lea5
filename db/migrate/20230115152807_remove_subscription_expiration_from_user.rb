# frozen_string_literal: true

class RemoveSubscriptionExpirationFromUser < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :subscription_expiration, :datetime
  end
end
