# frozen_string_literal: true

class AddNumberToInvoices < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL.squish
      CREATE SEQUENCE IF NOT EXISTS invoices_id_seq OWNED BY invoices.id;
      ALTER TABLE invoices ALTER COLUMN id SET DEFAULT nextval('invoices_id_seq');
    SQL

    execute <<~SQL.squish
      SELECT setval('invoices_id_seq', COALESCE((SELECT MAX(id) FROM invoices), 1));
    SQL

    # Create the column without the NOT NULL constraint, backfill values, then enable the constraint
    add_column :invoices, :number, :bigint

    execute <<~SQL.squish
      UPDATE invoices SET number = id
    SQL

    change_column_null :invoices, :number, false
    add_index :invoices, :number, unique: true

    execute <<~SQL.squish
      UPDATE settings
      SET key = 'next_invoice_number'
      WHERE key = 'next_invoice_id';
    SQL
  end

  def down
    remove_index :invoices, :number
    remove_column :invoices, :number

    execute <<~SQL.squish
      ALTER TABLE invoices
        ALTER COLUMN id DROP DEFAULT;
      DROP SEQUENCE IF EXISTS invoices_id_seq;
    SQL

    execute <<~SQL.squish
      UPDATE settings
      SET key = 'next_invoice_id'
      WHERE key = 'next_invoice_number';
    SQL
  end
end
