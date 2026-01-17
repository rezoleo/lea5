class CreateSalesWithTotals < ActiveRecord::Migration[7.2]
  def change
    create_view :sales_with_totals
  end
end
