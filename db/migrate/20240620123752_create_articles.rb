# frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :name, null: false
      t.integer :price, null: false
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
