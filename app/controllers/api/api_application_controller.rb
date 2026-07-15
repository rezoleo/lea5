# frozen_string_literal: true

module Api
  class ApiApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::StatementInvalid, with: :render_bad_request
    rescue_from CanCan::AccessDenied, with: :render_forbidden

    before_action :api_auth

    def current_ability
      @current_ability ||= ApiKeyAbility.new(@current_api_key)
    end

    private

    def api_auth
      @current_api_key = authenticate_with_http_token do |token, _options|
        ApiKey.authenticate_by_token token
      end

      render_unauthorized if @current_api_key.nil?
    end

    def render_unauthorized
      headers['WWW-Authenticate'] = 'Bearer realm="Application"'

      render json: {
        code: 'unauthorized',
        message: 'You need to provide a valid API key to access this resource.'
      }, status: :unauthorized
    end

    def render_not_found(_exception)
      render json: {
        code: 'not_found',
        message: 'The requested resource was not found.'
      }, status: :not_found
    end

    def render_bad_request(_exception)
      render json: {
        code: 'bad_request',
        message: 'The requested resource was invalid.'
      }, status: :bad_request
    end

    def render_forbidden(_exception)
      render json: {
        code: 'forbidden',
        message: 'You are not authorized to perform this action.'
      }, status: :forbidden
    end
  end
end
