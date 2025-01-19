# frozen_string_literal: true

class RemoveTotalPriceFromRefunds < ActiveRecord::Migration[7.1]
  def change
    remove_column :refunds, :total_price, :integer
  end
end
