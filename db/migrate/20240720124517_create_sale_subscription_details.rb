# frozen_string_literal: true

class CreateSaleSubscriptionDetails < ActiveRecord::Migration[7.0]
  def change
    # See previous migration for create_table vs. create_join_table rationale
    create_table :sales_subscription_offers, primary_key: [:sale_id, :subscription_offer_id] do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.references :sale, null: false, foreign_key: true
      t.references :subscription_offer, null: false, foreign_key: true
      t.integer :quantity, null: false
    end
  end
end
