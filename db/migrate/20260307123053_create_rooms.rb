# frozen_string_literal: true

class CreateRooms < ActiveRecord::Migration[7.2]
  def change
    create_table :rooms do |t|
      t.string :number, limit: 6, null: false
      t.string :group, limit: 6, null: false
      t.string :building, limit: 1, null: false
      t.integer :floor, null: false

      t.timestamps
    end
    add_index :rooms, :number, unique: true

    # Nullify any user rooms that don't exist in the rooms table
    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE users SET room = NULL
          WHERE room IS NOT NULL
          AND room NOT IN (SELECT number FROM rooms)
        SQL
      end
    end

    remove_index :users, :room, name: 'index_users_on_room'
    add_index :users, :room, unique: true, where: 'room IS NOT NULL', name: 'index_users_on_room'
    add_foreign_key :users, :rooms, column: :room, primary_key: :number
  end
end
