# frozen_string_literal: true

class ApiApiKeysController < ApiApplicationController
  # Require token authentication for index

  def index
    @api_keys = ApiKey.accessible_by(current_ability)
    authorize! :index, @api_keys
  end
end
