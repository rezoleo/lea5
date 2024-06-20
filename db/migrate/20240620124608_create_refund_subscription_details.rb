# frozen_string_literal: true

class CreateRefundSubscriptionDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :refund_subscription_details do |t|
      t.references :refund, null: false, foreign_key: true
      t.references :subscription_offer, null: false, foreign_key: true
      t.integer :duration

      t.timestamps
    end
  end
end
