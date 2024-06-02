# frozen_string_literal: true

class FixApiKey < ActiveRecord::Migration[7.0]
  def change
    change_table :api_keys do |t|
      t.remove :api_key_start_at,
               type: :datetime
    end
  end
end
