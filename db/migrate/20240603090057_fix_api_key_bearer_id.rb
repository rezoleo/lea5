# frozen_string_literal: true

class FixApiKeyBearerId < ActiveRecord::Migration[7.0]
  def change
    change_table :api_keys do |t|
      t.remove :bearer_id,
               type: :integer
    end
  end
end
