# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    user = User.upsert_from_auth_hash(request.env['omniauth.auth'])
    log_in user
    flash[:success] = 'You are now logged in!'
    if session[:redirect_url]
      redirect_to session.delete(:redirect_url)
      return
    end
    redirect_to user_path user
  end

  def destroy
    log_out
    flash[:success] = 'You are now logged out!'
    redirect_to root_path
  end
end
