# frozen_string_literal: true

class CreateSaleArticleDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :sale_article_details do |t|
      t.references :sale, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
