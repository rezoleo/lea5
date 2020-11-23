# frozen_string_literal: true

class Machine < ApplicationRecord
  validates :name, presence: true, allow_blank: false
  validates :mac, presence: true, allow_blank: false
end
