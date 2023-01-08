# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.integer :duration
      t.datetime :cancelled_at

      t.timestamps
    end
  end
end
