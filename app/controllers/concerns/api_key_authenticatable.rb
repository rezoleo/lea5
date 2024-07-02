# frozen_string_literal: true

module ApiKeyAuthenticatable
  extend ActiveSupport::Concern

  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Token::ControllerMethods

  attr_reader :current_api_key, :current_bearer

  private

  attr_writer :current_api_key, :current_bearer

  def authenticator(http_token)
    @current_api_key = ApiKey.authenticate_by_token! http_token

    current_api_key
  end
end
