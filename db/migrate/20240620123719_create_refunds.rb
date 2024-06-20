# frozen_string_literal: true

class CreateRefunds < ActiveRecord::Migration[7.0]
  def change
    create_table :refunds do |t|
      t.references :refunder, null: false, foreign_key: { to_table: :users }
      t.references :refund_method, null: false, foreign_key: { to_table: :payment_methods }
      t.references :sale, null: false, foreign_key: true
      t.references :invoice, null: false, foreign_key: true
      t.integer :total_price
      t.string :reason
      t.datetime :verified_at

      t.timestamps
    end
  end
end
