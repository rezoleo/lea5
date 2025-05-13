# frozen_string_literal: true

module Api
  class ApiApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :api_auth

    def current_ability
      @current_ability ||= ApiKeyAbility.new(@current_api_key)
    end

    private

    def api_auth
      @current_api_key = authenticate_or_request_with_http_token do |token, _options|
        ApiKey.authenticate_by_token token
      end
    end
  end
end
