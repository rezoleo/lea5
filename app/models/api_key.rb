# frozen_string_literal: true

class ApiKey < ApplicationRecord
  HMAC_SECRET_KEY = Rails.application.credentials.api_key_hmac_secret_key!

  validates :name, presence: true, allow_blank: false

  before_create :generate_token_hmac_digest

  attr_accessor :api_key

  def self.authenticate_by_token(api_key)
    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, api_key

    find_by api_key_digest: digest
  end

  private

  def generate_token_hmac_digest
    @api_key = "Lea5_#{SecureRandom.base58(24)}"

    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, @api_key
    self.api_key_digest = digest
  end
end
