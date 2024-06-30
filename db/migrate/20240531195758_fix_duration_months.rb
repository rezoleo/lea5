# frozen_string_literal: true

class FixDurationMonths < ActiveRecord::Migration[7.0]
  def change
    change_table :subscriptions, bulk: true do |t|
      t.remove :duration,
               type: :integer
      t.virtual :duration,
                type: :integer,
                as: "extract(year from age(date_trunc('months', end_at), date_trunc('months', start_at))) * 12 +
      extract(month from age(date_trunc('months', end_at), date_trunc('months', start_at)))",
                stored: true,
                comment: 'Duration in months'
    end
  end
end
