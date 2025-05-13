# frozen_string_literal: true

module Api
  class ApiKeysController < ApiApplicationController
    def index
      @api_keys = ApiKey.accessible_by(current_ability)
    end
  end
end
