# frozen_string_literal: true

class AddKeycloakIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :keycloak_id, :string
    add_index :users, :keycloak_id, unique: true
  end
end
