# frozen_string_literal: true

class CreateRooms < ActiveRecord::Migration[7.2]
  def change
    create_table :rooms do |t|
      t.string :number, limit: 6, null: false
      t.string :group, limit: 6, null: false
      t.string :building, limit: 1, null: false
      t.integer :floor, null: false
      t.references :user, foreign_key: true, index: { unique: true, where: 'user_id IS NOT NULL' }

      t.timestamps
    end
    add_index :rooms, :number, unique: true
    add_index :rooms, :group
    add_index :rooms, [:building, :floor]

    # Migrate existing user.room data to rooms.user_id
    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE rooms SET user_id = users.id FROM users WHERE users.room = rooms.number
        SQL
      end
    end

    # Remove the old room column from users
    remove_index :users, :room, name: 'index_users_on_room'
    remove_column :users, :room, :string
  end
end
