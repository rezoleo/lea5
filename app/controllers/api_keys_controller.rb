# frozen_string_literal: true

# Hello from demo
class ApiKeysController < ApplicationController
  def index
    @api_keys = ApiKey.accessible_by(current_ability)
  end

  def new
    @api_key = ApiKey.new
    authorize! :new, @api_key
  end

  def create
    @api_key = ApiKey.new(api_key_params)
    authorize! :create, @api_key
    if @api_key.save
      flash[:new_api_key] = "ApiKey added! It is #{@api_key.api_key}"
      redirect_to api_keys_url
    else
      render 'new', status: :unprocessable_entity
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
    params.require(:api_key).permit(:name)
  end
end
