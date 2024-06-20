# frozen_string_literal: true

class CreateSaleSubscriptionDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :sale_subscription_details do |t|
      t.references :sale, null: false, foreign_key: true
      t.references :subscription_offer, null: false, foreign_key: true
      t.integer :duration

      t.timestamps
    end
  end
end
