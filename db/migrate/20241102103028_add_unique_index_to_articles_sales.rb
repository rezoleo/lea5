# frozen_string_literal: true

class AddUniqueIndexToArticlesSales < ActiveRecord::Migration[7.1]
  def change
    add_index :articles_sales, [:article_id, :sale_id], unique: true
  end
end
