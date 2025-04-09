# frozen_string_literal: true

class CreatePaymentMethods < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_methods do |t|
      t.string :name, null: false
      t.boolean :auto_verify, default: false, null: false
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
