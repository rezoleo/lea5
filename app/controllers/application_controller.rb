# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Rails 7.2 added by default a "browser guard" to filter out "old" browsers based on their user agent.
  # This is very user hostile: for most users and websites, a *maybe* *partially* broken app is better
  # than actively denying them entry (without even considering the fact that not everyone uses a "mainstream"
  # browser, it excludes terminal browsers, browsers/scripts that don't send a user agent, or unrecognized browsers
  # that would support the website but are excluded without trying, and that the user agent is an unreliable source
  # of information where every browser lies anyway).
  # The PR [1] adding this cites "webp images, web push, badges, import maps, CSS nesting, and CSS :has".
  # The only feature we currently use (and vaguely "need") in this list is import maps, and we can always include
  # the shim for it.
  # Everything else is either not needed or can gracefully degrade in browsers without support.
  # [1]: https://github.com/rails/rails/pull/50505

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
