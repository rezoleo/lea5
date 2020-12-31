# frozen_string_literal: true

require 'resolv'

class Ip < ApplicationRecord
  belongs_to :machine, optional: true

  validates :ip, presence: true, format: { with: Resolv::IPv4::Regex }, uniqueness: true
end
