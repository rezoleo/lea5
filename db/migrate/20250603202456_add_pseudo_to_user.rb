# frozen_string_literal: true

class AddPseudoToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :pseudo, :string, null: false # rubocop:disable Rails/NotNullColumn
    add_index :users, :pseudo, unique: true
  end
end
