# frozen_string_literal: true

class CreateSaleArticleDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :articles_sales do |t|
      t.references :sale, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
    # create_join_table :sales, :articles, column_options: { foreign_key: true } do |t|
    #   t.integer :quantity, null: false
    # end
  end
end
