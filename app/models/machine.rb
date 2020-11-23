# frozen_string_literal: true

class Machine < ApplicationRecord
  validates :name, presence: true, allow_blank: false
  VALID_MAC_REGEX = /\A((\h{2}:){5}\h{2}|(\h{2}-){5}\h{2}|(\h{2}){5}\h{2})\z/i.freeze
  validates :mac, presence: true, format: { with: VALID_MAC_REGEX },
                  uniqueness: { unless: ->(machine) { machine.errors.include?(:mac) } }
end
