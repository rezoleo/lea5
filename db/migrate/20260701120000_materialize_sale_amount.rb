# frozen_string_literal: true

class MaterializeSaleAmount < ActiveRecord::Migration[7.2]
  def up
    add_column :sales, :amount_cents, :bigint, null: false, default: 0

    # Backfill existing sales.
    execute <<~SQL.squish
      UPDATE sales SET amount_cents =
        COALESCE((SELECT SUM(asl.quantity * ar.price_cents)
                  FROM articles_sales asl JOIN articles ar ON ar.id = asl.article_id
                  WHERE asl.sale_id = sales.id), 0)
        + COALESCE((SELECT SUM(sso.quantity * so.price_cents)
                    FROM sales_subscription_offers sso
                    JOIN subscription_offers so ON so.id = sso.subscription_offer_id
                    WHERE sso.sale_id = sales.id), 0)
    SQL

    add_column :refunds, :amount_cents, :bigint, null: false, default: 0

    # Backfill existing refunds.
    execute <<~SQL.squish
      UPDATE refunds SET amount_cents =
        COALESCE((SELECT SUM(arf.quantity * ar.price_cents)
                  FROM articles_refunds arf JOIN articles ar ON ar.id = arf.article_id
                  WHERE arf.refund_id = refunds.id), 0)
        + COALESCE(refunds.subscription_refund_cents, 0)
    SQL
  end

  def down
    remove_column :sales, :amount_cents
    remove_column :refunds, :amount_cents
  end
end
