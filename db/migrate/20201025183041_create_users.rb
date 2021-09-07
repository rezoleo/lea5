# typed: true
# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :firstname, null: false
      t.string :lastname, null: false
      t.string :email, null: false, index: { unique: true }
      t.string :room, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
