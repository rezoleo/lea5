# frozen_string_literal: true

class RemoveUserFromSubscriptions < ActiveRecord::Migration[7.0]
  def change
    remove_column :subscriptions, :user_id, :integer
  end
end
