# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :still_authenticated?

  private

  def still_authenticated?
    log_out if should_log_out?
  end
end
