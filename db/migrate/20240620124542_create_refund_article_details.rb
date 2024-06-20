# frozen_string_literal: true

class CreateRefundArticleDetails < ActiveRecord::Migration[7.0]
  def change
    create_join_table :refunds, :articles, column_options: { foreign_key: true } do |t|
      t.integer :quantity, null: false
    end
    # create_table :refund_article_details do |t|
    #   t.references :refund, null: false, foreign_key: true
    #   t.references :article, null: false, foreign_key: true
    #   t.integer :quantity
    #
    #   t.timestamps
    # end
  end
end
