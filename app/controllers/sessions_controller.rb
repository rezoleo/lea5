# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    user = User.upsert_from_auth_hash(request.env['omniauth.auth'])
    log_in user
    flash[:success] = 'You are now logged in!'
    redirect_to profile_path
  end

  def create_developer
    auth_hash = request.env['omniauth.auth']['info']
    user = User.find_or_initialize_by(email: auth_hash[:email])
    user.update!(firstname: auth_hash[:first_name], lastname: auth_hash[:last_name], username: auth_hash[:username])
    user.groups = auth_hash[:groups].split(',')
    log_in user
    flash[:success] = 'You are now logged in (using developer method)!'
    redirect_to profile_path
  end

  def destroy
    log_out
    flash[:success] = 'You are now logged out!'
    redirect_to root_path
  end
end
