# frozen_string_literal: true

class RemoveDurationAddStartAtEndAtToSubscription < ActiveRecord::Migration[7.0]
  def change
    change_table :subscriptions, bulk: true do |t|
      t.remove :duration, type: :integer
      # rubocop:disable Rails/NotNullColumn
      # We disable this cop here because it was introduced in a new rubocop-rails version,
      # and this migration already existed. Let's not change it now.
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      # rubocop:enable Rails/NotNullColumn
    end
  end
end
