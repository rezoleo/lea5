# frozen_string_literal: true

class ApiApplicationController < ActionController::Base # rubocop:disable Rails/ApplicationController
  include ApiKeyAuthenticatable

  before_action :api_auth

  def current_ability
    @current_ability ||= ApiKeyAbility.new(@current_bearer)
  end

  private

  def api_auth
    current_bearer = authenticate_or_request_with_http_token { |token, _options| authenticator(token) }
    @current_bearer = ApiKey.find(current_bearer.id)
  end
end
