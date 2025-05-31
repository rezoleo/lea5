# frozen_string_literal: true

class AddWifiPasswordToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :wifi_password, :string, null: false # rubocop:disable Rails/NotNullColumn
    add_index :users, :wifi_password, unique: true
  end
end
