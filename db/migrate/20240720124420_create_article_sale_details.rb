# frozen_string_literal: true

class CreateArticleSaleDetails < ActiveRecord::Migration[7.0]
  def change
    # We use a standard create_table instead of create_join_table, because the latter
    # doesn't let us add a primary key (we want a composite key spanning both columns),
    # and Rails cannot destroy the relation if there is no primary key.
    # The error looks like the generated SQL doesn't have the correct column:
    #   ERROR:  zero-length delimited identifier at or near """" (PG::SyntaxError)
    #   LINE 1: ...ription_offers" WHERE "sales_subscription_offers"."" IS NULL
    create_table :articles_sales, primary_key: [:article_id, :sale_id] do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.references :article, null: false, foreign_key: true
      t.references :sale, null: false, foreign_key: true
      t.integer :quantity, null: false
    end

    # This does NOT work
    # create_join_table :articles, :sales, column_options: { foreign_key: true } do |t|
    #   t.integer :quantity, null: false
    # end
  end
end
