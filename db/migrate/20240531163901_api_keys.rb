# frozen_string_literal: true

class ApiKeys < ActiveRecord::Migration[7.0]
  def change
    create_table :api_keys do |t|
      t.integer :bearer_id, null: false, index: { unique: true }
      t.string :bearer_name, null: false
      t.string :api_key, null: false, index: { unique: true }
      t.datetime :api_key_start_at, index: { unique: true }

      t.timestamps
    end
  end
end
