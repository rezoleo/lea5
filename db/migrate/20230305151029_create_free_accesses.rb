# frozen_string_literal: true

class CreateFreeAccesses < ActiveRecord::Migration[7.0]
  def change
    create_table :free_accesses do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.string :reason, limit: 255, null: false

      t.timestamps
    end
  end
end
