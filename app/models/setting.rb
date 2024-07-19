# frozen_string_literal: true

class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  def self.next_invoice_id
    record = lock(true).get_or_create(key: 'next_invoice_id', default: 1)
    next_id = record.value.to_i
    record.update!(value: next_id + 1)
    next_id
  end

  def self.get_or_create(key:, default: nil)
    record = find_or_create_by(key: key)
    record.value = default unless record.persisted?
    record
  end
end
