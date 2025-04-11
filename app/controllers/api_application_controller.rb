# frozen_string_literal: true

class ApiApplicationController < ActionController::Base # rubocop:disable Rails/ApplicationController
  include ApiKeyAuthenticatable

  before_action :api_auth

  def current_ability
    @current_ability ||= ApiKeyAbility.new(@current_bearer)
  end

  private

  def api_auth
    current_bearer = authenticate_with_api_key
    @current_bearer = if current_bearer.nil?
                        nil
                      else
                        ApiKey.find(current_bearer.id)
                      end
  end
end
