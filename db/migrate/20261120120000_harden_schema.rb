# frozen_string_literal: true

class HardenSchema < ActiveRecord::Migration[8.1]
  def change
    remove_index :subscriptions, :sale_id
    add_index :subscriptions, :sale_id, unique: true
    remove_index :sales, :invoice_id
    add_index :sales, :invoice_id, unique: true
    remove_index :refunds, :invoice_id
    add_index :refunds, :invoice_id, unique: true

    remove_index :users, :wifi_password

    add_reference :free_accesses, :created_by, foreign_key: { to_table: :users, on_delete: :nullify }
  end
end
