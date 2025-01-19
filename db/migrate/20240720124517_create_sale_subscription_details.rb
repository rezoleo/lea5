# frozen_string_literal: true

class CreateSaleSubscriptionDetails < ActiveRecord::Migration[7.0]
  def change
    create_join_table :sales, :subscription_offers, column_options: { foreign_key: true } do |t|
      t.integer :duration, null: false
    end
    # create_table :sales_subscription_offers do |t|
    #   t.references :sale, null: false, foreign_key: true
    #   t.references :subscription_offer, null: false, foreign_key: true
    #   t.integer :duration
    #
    #   t.timestamps
    # end
  end
end
