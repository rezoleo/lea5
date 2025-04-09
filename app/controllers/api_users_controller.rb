# frozen_string_literal: true

class ApiUsersController < ApiApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  def index
    @users = User.accessible_by(current_ability)
    authorize! :index, @users
  end

  def show
    @user = User.find(params[:id])
    authorize! :show, @user
    @machines = @user.machines.includes(:ip).order(created_at: :asc)
    @subscriptions = @user.subscriptions.order(created_at: :desc)
    @free_accesses = @user.free_accesses.order(created_at: :desc)
  end
end
