# frozen_string_literal: true

class MakeRoomNullableInUsers < ActiveRecord::Migration[7.2]
  def change
    change_column_null :users, :room, true
    remove_index :users, :room
    add_index :users, :room, unique: true, where: 'room IS NOT NULL'
  end
end
