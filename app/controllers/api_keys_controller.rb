# frozen_string_literal: true

class ApiKeysController < ApplicationController
  include ApiKeyAuthenticatable
  include SessionsHelper

  # Require token authentication for index

  def index
    @api_keys = ApiKey.accessible_by(current_ability)
    authorize! :index, @api_keys
  end

  def new
    @api_key = ApiKey.new
    authorize! :new, @api_key
  end

  def create
    @api_key = ApiKey.new(api_key_params)
    authorize! :create, @api_key
    respond_to do |format|
      if @api_key.save
        format.html do
          flash[:success] = "ApiKey added! It is #{@api_key.key}"
          redirect_to api_keys_url
        end
      else
        format.html { render 'new', status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @api_key = ApiKey.find(params[:id])
    authorize! :destroy, @api_key
    @api_key.destroy
    flash[:success] = 'ApiKey deleted!'
    redirect_to api_keys_url
  end

  private

  def api_key_params
    params.require(:api_key).permit(:bearer_name)
  end
end
