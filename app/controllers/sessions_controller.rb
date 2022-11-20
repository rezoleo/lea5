# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    user = User.upsert_from_auth_hash(request.env['omniauth.auth'])
    log_in user
    redirect_to user_path user
  end

  def destroy
    log_out
    redirect_to users_path
  end
end
