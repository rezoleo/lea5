# frozen_string_literal: true

class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices, id: :bigint, default: nil do |t|
      t.jsonb :generation_json, null: false

      t.timestamps
    end
  end
end
