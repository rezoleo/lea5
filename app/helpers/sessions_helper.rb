# frozen_string_literal: true

module SessionsHelper
  def current_user
    return nil if session[:user_id].nil?

    @current_user ||= User.find(session[:user_id])
    @current_user&.groups = session[:groups]
    @current_user
  end

  def current_bearer
    return nil if session[:api_key_id].nil?

    @current_bearer = ApiKey.find(session[:api_key_id])
    @current_bearer
  end

  def logged_in?
    !current_user.nil?
  end

  def log_in(user)
    reset_session # For security reasons, we clear the session data before login
    session[:user_id] = user.id
    session[:expires_at] = Time.current + SESSION_DURATION_TIME
    session[:groups] = user.groups
  end

  def log_in_api(bearer)
    reset_session # For security reasons, we clear the session data before login
    session[:api_key_id] = bearer.id
    session[:expires_at] = Time.current + SESSION_DURATION_TIME
  end

  # TODO: also logout of sso
  def log_out
    reset_session
  end

  def should_log_out?
    session[:expires_at] && session[:expires_at].to_time < Time.current
  end
end
