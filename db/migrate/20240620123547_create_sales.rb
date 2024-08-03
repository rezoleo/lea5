# frozen_string_literal: true

class CreateSales < ActiveRecord::Migration[7.0]
  def change
    create_table :sales do |t|
      t.references :seller, null: true, foreign_key: { to_table: :users }
      t.references :client, null: false, foreign_key: { to_table: :users }
      t.references :payment_method, null: false, foreign_key: true
      t.references :invoice, null: false, foreign_key: true
      t.integer :total_price
      t.datetime :verified_at

      t.timestamps
    end
  end
end
