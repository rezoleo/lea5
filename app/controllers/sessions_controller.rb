# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    user = User.upsert_from_auth_hash(request.env['omniauth.auth'])
    log_in user
    flash[:success] = 'You are now logged in!'
    redirect_to user_path user
  end

  def create_developer # rubocop: disable Metrics/AbcSize
    user = User.find_or_create_by!(
      email: params[:email]
    ) do |u|
      u.firstname = params[:firstname]
      u.lastname = params[:lastname]
      u.room = params[:room]
    end
    user.groups = params[:groups].split(',')
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
