# frozen_string_literal: true

class ApiKeysController < ApplicationController
  def index
    @api_key = ApiKey.accessible_by(current_ability)
  end

  def new
    @api_key = ApiKey.new
  end

  def create
    @api_key = ApiKey.new(api_key_params)
  end

  def destroy
    @api_key.destroy
  end

  private

  def api_key_params
    params.require(:api_key).permit(:bearer_name)
  end
end
