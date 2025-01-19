# frozen_string_literal: true

class RemoveTotalPriceFromSales < ActiveRecord::Migration[7.1]
  def change
    remove_column :sales, :total_price, :integer
  end
end
