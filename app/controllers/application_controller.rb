# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :still_authenticated?

  # https://cancancan.dev/handling_access_denied
  rescue_from CanCan::AccessDenied do |exception|
    if current_user.nil?
      session[:redirect_url] = request.fullpath
      redirect_to root_url, alert: 'You have to log in to continue.'
    else
      respond_to do |format|
        format.json { render nothing: true, status: :not_found }
        format.html { redirect_to root_url, alert: exception.message }
      end
    end
  end

  private

  def still_authenticated?
    log_out if should_log_out?
  end
end
