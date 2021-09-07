# typed: true
# frozen_string_literal: true

class AddUsersToMachines < ActiveRecord::Migration[6.0]
  def change
    add_reference :machines, :user, foreign_key: true, null: false # rubocop:disable Rails/NotNullColumn
  end
end
