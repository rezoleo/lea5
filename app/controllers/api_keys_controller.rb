# frozen_string_literal: true

class ApiKeysController < ApplicationController
  def index
    @api_key = ApiKey.accessible_by(current_ability)
  end

  def new
    @api_key = ApiKey.new
  end

  def create
    @api_key = ApiKey.new(bearer_name: :bearer_name, token: generate_token)
    respond_to do |format|
      if @api_key.save
        format.html do
          flash[:success] = 'ApiKey added!'
        end
      else
        format.html { render 'new', status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @api_key.destroy
  end

  private

  def api_key_params
    params.require(:api_key).permit(:bearer_name)
  end
end
