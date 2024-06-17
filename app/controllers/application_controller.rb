# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :still_authenticated?

  def current_ability
    @current_ability ||= if session[:api_key_id].nil?
                           UserAbility.new(current_user)
                         else
                           ApiKeyAbility.new(current_bearer)
                         end
  end

  private

  def still_authenticated?
    log_out if should_log_out?
  end
end
