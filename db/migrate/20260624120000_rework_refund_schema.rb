# frozen_string_literal: true

class ReworkRefundSchema < ActiveRecord::Migration[7.2]
  def change
    # Store the prorated subscription credit. NULL means the refund did not cut a
    # subscription; a value (including 0) means it did. This is the one non-derivable
    # amount of a refund (article credits stay derivable from articles_refunds).
    add_column :refunds, :subscription_refund_cents, :integer

    # A refund cuts the sale's single subscription as a unit and credits a prorated
    # amount, so the per-offer breakdown is redundant (reachable via refund -> sale)
    # and its quantity no longer drives the credit. subscription_refund_cents replaces
    # it as both the amount and the "subscription was cut" marker.
    drop_table :refunds_subscription_offers, primary_key: [:refund_id, :subscription_offer_id] do |t|
      t.references :refund, null: false, foreign_key: true
      t.references :subscription_offer, null: false, foreign_key: true
      t.integer :quantity, null: false
    end

    remove_foreign_key :refunds, :users, column: :refunder_id
    add_foreign_key :refunds, :users, column: :refunder_id, on_delete: :nullify
  end
end
