# frozen_string_literal: true

class RemoveDurationAddStartAtEndAtToSubscription < ActiveRecord::Migration[7.0]
  def change
    change_table :subscriptions, bulk: true do |t|
      t.remove :duration, type: :integer
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
    end
  end
end
