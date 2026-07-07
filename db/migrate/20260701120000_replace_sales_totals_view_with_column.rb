# frozen_string_literal: true

class ReplaceSalesTotalsViewWithColumn < ActiveRecord::Migration[7.2]
  def up
    add_column :sales, :total_cents, :bigint, null: false, default: 0

    # Backfill existing sales from their (immutable) line items.
    execute <<~SQL.squish
      UPDATE sales SET total_cents =
        COALESCE((SELECT SUM(asl.quantity * ar.price_cents)
                  FROM articles_sales asl
                  JOIN articles ar ON ar.id = asl.article_id
                  WHERE asl.sale_id = sales.id), 0)
        + COALESCE((SELECT SUM(sso.quantity * so.price_cents)
                    FROM sales_subscription_offers sso
                    JOIN subscription_offers so ON so.id = sso.subscription_offer_id
                    WHERE sso.sale_id = sales.id), 0)
    SQL
  end

  def down
    remove_column :sales, :total_cents
  end
end
