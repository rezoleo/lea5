# frozen_string_literal: true

class AddDateEndSubscriptionToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :date_end_subscription, :datetime
  end
end
