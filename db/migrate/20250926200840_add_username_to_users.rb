# frozen_string_literal: true

class AddUsernameToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :username, :string, null: false # rubocop:disable Rails/NotNullColumn
    add_index :users, :username, unique: true
  end
end
