# frozen_string_literal: true

class CreateApiKeys < ActiveRecord::Migration[7.2]
  def change
    create_table :api_keys do |t|
      t.string :name, null: false
      t.string :api_key_digest, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
