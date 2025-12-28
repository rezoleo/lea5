# frozen_string_literal: true

MoneyRails.configure do |config|
  config.default_currency = :eur
  config.rounding_mode = BigDecimal::ROUND_HALF_UP
  config.locale_backend = :i18n
end
