# frozen_string_literal: true

class ApiKey < ApplicationRecord
  validates :bearer_name, presence: true, allow_blank: false

  before_validation :set_key, on: :create

  private

  def set_key
    token = SecureRandom.hex
    self.api_key = token
  end
end
