# frozen_string_literal: true

class CreateRe2oAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :re2o_accounts do |t|
      t.string :pseudo, null: false, index: { unique: true }
      t.string :email, index: true
      t.string :firstname
      t.string :lastname
      t.string :room
      t.datetime :end_at, null: false
      t.jsonb :machines, null: false, default: []
      t.string :ntlm_hash
      t.references :claimed_by_user, foreign_key: { to_table: :users, on_delete: :nullify },
                                     index: { unique: true, where: 'claimed_by_user_id IS NOT NULL' }
      t.datetime :claimed_at
      t.jsonb :claim_report
      t.timestamps
    end
  end
end
