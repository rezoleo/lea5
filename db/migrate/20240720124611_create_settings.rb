# frozen_string_literal: true

class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings do |t|
      t.string :key, null: false
      t.string :value, null: false
      t.timestamps
    end
    add_index :settings, :key, unique: true
  end
end
