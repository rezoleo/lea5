# frozen_string_literal: true

class CreateArticleRefundDetails < ActiveRecord::Migration[7.0]
  def change
    # See previous migration for create_table vs. create_join_table rationale
    create_table :articles_refunds, primary_key: [:article_id, :refund_id] do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.references :article, null: false, foreign_key: true
      t.references :refund, null: false, foreign_key: true
      t.integer :quantity, null: false
    end
  end
end
