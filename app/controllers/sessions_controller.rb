# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    user = User.upsert_from_auth_hash(request.env['omniauth.auth'])
    log_in user
    flash[:success] = 'You are now logged in!'
    redirect_to user_path user
  end

  def create_developer
    auth_hash = request.env['omniauth.auth']['info']
    user = User.find_or_create_by!(
      email: auth_hash[:email]
    ) do |u|
      u.firstname = auth_hash[:first_name]
      u.lastname = auth_hash[:last_name]
      u.username = auth_hash[:username]
      u.room = auth_hash[:room]
    end
    user.groups = auth_hash[:groups].split(',')
    log_in user
    flash[:success] = 'You are now logged in (using developer method)!'
    redirect_to user
  end

  def destroy
    log_out
    flash[:success] = 'You are now logged out!'
    redirect_to root_path
  end
end
