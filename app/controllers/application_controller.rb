# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper
  include ApiKeyAuthenticatable

  before_action :still_authenticated?

  def current_ability
    @current_ability ||= UserAbility.new(current_user)
  end

  private

  def still_authenticated?
    log_out if should_log_out?
  end
end
