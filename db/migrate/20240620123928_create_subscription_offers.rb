# frozen_string_literal: true

class CreateSubscriptionOffers < ActiveRecord::Migration[7.0]
  def change
    create_table :subscription_offers do |t|
      t.integer :duration
      t.integer :price
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
