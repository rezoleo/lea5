# frozen_string_literal: true

module ApiKeyAuthenticatable
  extend ActiveSupport::Concern

  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Token::ControllerMethods

  attr_reader :current_api_key, :current_bearer

  # Use this to raise an error and automatically respond with a 401 HTTP status
  # code when API key authentication fails
  def authenticate_with_api_key!
    @current_bearer = authenticate_or_request_with_http_token { |token, _options| authenticator(token) }
  end

  # Use this for optional API key authentication
  def authenticate_with_api_key
    @current_bearer = authenticate_with_http_token { |token, _options| authenticator(token) }
  end

  private

  attr_writer :current_api_key, :current_bearer

  def authenticator(http_token)
    @current_api_key = ApiKey.authenticate_by_token api_key: http_token

    current_api_key
  end
end
