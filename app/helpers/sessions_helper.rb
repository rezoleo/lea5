# frozen_string_literal: true

module SessionsHelper
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !current_user.nil?
  end

  def log_in(user)
    reset_session # For security reasons, we clear the session data before login
    session[:user_id] = user.id
  end
end
