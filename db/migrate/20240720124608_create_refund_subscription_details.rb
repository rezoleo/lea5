# frozen_string_literal: true

class CreateRefundSubscriptionDetails < ActiveRecord::Migration[7.0]
  def change
    # See previous migration for create_table vs. create_join_table rationale
    create_table :refunds_subscription_offers, primary_key: [:refund_id, :subscription_offer_id] do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.references :refund, null: false, foreign_key: true
      t.references :subscription_offer, null: false, foreign_key: true
      t.integer :quantity, null: false
    end
  end
end
