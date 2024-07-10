# frozen_string_literal: true

class ApiKey < ApplicationRecord
  HMAC_SECRET_KEY = Rails.application.credentials.api_key_hmac_secret_key!

  validates :bearer_name, presence: true, allow_blank: false

  before_create :generate_token_hmac_digest

  attr_accessor :key

  def self.authenticate_by_token!(key)
    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, key

    find_by! api_key: digest
  end

  private

  def generate_token_hmac_digest
    @key = SecureRandom.hex(32)

    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, @key
    self.api_key = digest
  end
end
