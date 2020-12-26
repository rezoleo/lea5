# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :payment, null: false
      t.integer :duration, null: false
      t.datetime :date, null: false

      t.timestamps
    end
  end
end
