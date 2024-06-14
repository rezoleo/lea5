# frozen_string_literal: true

class SessionsController < ApplicationController
  include ApiKeyAuthenticatable
  def create
    if request.path == '/auth/api'
      current_bearer = authenticate_or_request_with_http_token { |token, _options| authenticator(token) }
      log_in_api current_bearer
      render json: flash[:success] = 'You are now logged in!'
    else
      user = User.upsert_from_auth_hash(request.env['omniauth.auth'])
      log_in user
      flash[:success] = 'You are now logged in!'
      redirect_to user_path user
    end
  end

  def destroy
    log_out
    flash[:success] = 'You are now logged out!'
    redirect_to root_path
  end
end
