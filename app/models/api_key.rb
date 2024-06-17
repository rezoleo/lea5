# frozen_string_literal: true

class ApiKey < ApplicationRecord
  HMAC_SECRET_KEY = ENV.fetch('API_KEY_HMAC_SECRET_KEY')

  validates :bearer_name, presence: true, allow_blank: false

  before_create :generate_token_hmac_digest

  attr_accessor :key

  def self.authenticate_by_token!(key)
    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, key

    find_by! api_key: digest
  end

  def serializable_hash(options = nil)
    h = super(options.merge(except: 'api_key'))
    h['api_key'] = key if key.present?
    h
  end

  private

  def generate_token_hmac_digest
    @key = SecureRandom.hex(32)

    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, @key
    self.api_key = digest
  end
end
