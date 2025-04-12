# frozen_string_literal: true

class AddSaleIdToSubscriptions < ActiveRecord::Migration[7.0]
  def change
    add_reference :subscriptions, :sale, null: false, foreign_key: true # rubocop:disable Rails/NotNullColumn
  end
end
