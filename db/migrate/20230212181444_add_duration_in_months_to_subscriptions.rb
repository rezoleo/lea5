# frozen_string_literal: true

class AddDurationInMonthsToSubscriptions < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :duration, :integer,
               as: "extract('months' from age(end_at, start_at))",
               stored: true,
               comment: 'Duration in months'
  end
end
