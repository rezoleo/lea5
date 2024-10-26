# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper
  include ApiKeyAuthenticatable

  before_action :still_authenticated?
  before_action :api_auth

  def current_ability
    @current_ability ||= if !session[:api_key_id].nil?

                           ApiKeyAbility.new(current_bearer)
                         elsif !session[:user_id].nil?
                           UserAbility.new(current_user)
                         else
                           UserAbility.new(nil)
                         end
  end

  private

  def still_authenticated?
    log_out if should_log_out?
  end

  def api_auth
    return unless request.path[0, 5] == '/api/'

    current_bearer = authenticate_or_request_with_http_token { |token, _options| authenticator(token) }
    log_in_api current_bearer
  end
end
