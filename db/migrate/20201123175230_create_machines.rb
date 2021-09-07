# typed: true
# frozen_string_literal: true

class CreateMachines < ActiveRecord::Migration[6.0]
  def change
    create_table :machines do |t|
      t.string :name, null: false
      t.macaddr :mac, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
