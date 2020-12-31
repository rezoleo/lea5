# frozen_string_literal: true

class CreateIps < ActiveRecord::Migration[6.0]
  def change
    create_table :ips do |t|
      t.inet :ip, null: false, index: { unique: true }
      t.references :machine, foreign_key: true

      t.timestamps
    end
  end
end
