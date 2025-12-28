# frozen_string_literal: true

class RenamePriceToPriceCents < ActiveRecord::Migration[7.2]
  def change
    rename_column :articles, :price, :price_cents
    rename_column :subscription_offers, :price, :price_cents
  end
end
