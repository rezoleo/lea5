# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.integer :duration, null: false
      t.datetime :cancelled_date

      t.timestamps
    end
  end
end
