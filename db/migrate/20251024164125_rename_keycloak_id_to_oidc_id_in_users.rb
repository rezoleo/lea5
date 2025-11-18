# frozen_string_literal: true

class RenameKeycloakIdToOidcIdInUsers < ActiveRecord::Migration[7.2]
  def up
    rename_column :users, :keycloak_id, :oidc_id
    # Rails automatically updates the index name when renaming a column in PostgreSQL
    # But we need to ensure the index name is updated for consistency
    if index_exists?(:users, :keycloak_id, name: 'index_users_on_keycloak_id')
      rename_index :users, :index_users_on_keycloak_id, :index_users_on_oidc_id
    elsif index_exists?(:users, :oidc_id) && !index_name_exists?(:users, :index_users_on_oidc_id)
      # Index exists with old name after column rename - rename it
      execute 'ALTER INDEX index_users_on_keycloak_id RENAME TO index_users_on_oidc_id'
    end
  end

  def down
    rename_column :users, :oidc_id, :keycloak_id
    if index_exists?(:users, :oidc_id, name: 'index_users_on_oidc_id')
      rename_index :users, :index_users_on_oidc_id, :index_users_on_keycloak_id
    elsif index_exists?(:users, :keycloak_id) && !index_name_exists?(:users, :index_users_on_keycloak_id)
      execute 'ALTER INDEX index_users_on_oidc_id RENAME TO index_users_on_keycloak_id'
    end
  end
end
