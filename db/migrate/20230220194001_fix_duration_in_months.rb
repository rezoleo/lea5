# frozen_string_literal: true

class FixDurationInMonths < ActiveRecord::Migration[7.0]
  def change
    change_table :subscriptions, bulk: true do |t|
      t.remove :duration,
               type: :integer,
               as: 'extract(month from age(end_at, start_at))',
               stored: true,
               comment: 'Duration in months'
      t.virtual :duration,
                type: :integer,
                as: 'extract(year from age(end_at, start_at)) * 12 + extract(month from age(end_at, start_at))',
                stored: true,
                comment: 'Duration in months'
    end
  end
end
