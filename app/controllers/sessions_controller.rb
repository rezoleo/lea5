# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    user = User.upsert_from_auth_hash(request.env['omniauth.auth'])
    log_in user
    session[:sso] = true
    flash[:success] = 'You are now logged in!'
    redirect_to profile_path
  end

  def create_developer
    auth_hash = request.env['omniauth.auth']['info']
    user = User.find_or_create_by!(
      email: auth_hash[:email]
    ) do |u|
      u.firstname = auth_hash[:first_name]
      u.lastname = auth_hash[:last_name]
      u.username = auth_hash[:username]
    end
    user.groups = auth_hash[:groups].split(',')
    log_in user
    flash[:success] = 'You are now logged in (using developer method)!'
    redirect_to profile_path
  end

  def failure
    flash[:error] = "Login failed: #{params[:message].to_s.humanize}"
    redirect_to root_path
  end

  def destroy
    sso = session[:sso]
    log_out
    flash[:success] = 'You are now logged out!'
    client_id = Rails.application.credentials.sso_id
    return redirect_to root_path unless sso && client_id

    logout_params = { client_id: client_id, post_logout_redirect_uri: root_url }
    redirect_to "#{SSO_LOGOUT_URL}?#{logout_params.to_query}", allow_other_host: true
  end
end
