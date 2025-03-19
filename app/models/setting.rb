# frozen_string_literal: true

class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  def self.next_invoice_id!
    record = Setting.lock.find_or_create_by!(key: 'next_invoice_id') do |setting|
      setting.value = 1
    end
    next_id = record.value.to_i
    record.update!(value: next_id + 1)
    next_id
  end
end
