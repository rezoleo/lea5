# frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :name
      t.integer :price
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
