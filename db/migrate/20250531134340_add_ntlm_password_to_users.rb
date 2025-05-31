# frozen_string_literal: true

class AddNtlmPasswordToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :ntlm_password, :string, null: false # rubocop:disable Rails/NotNullColumn
    add_index :users, :ntlm_password, unique: true
  end
end
