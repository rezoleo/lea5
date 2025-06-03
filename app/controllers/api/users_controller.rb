# frozen_string_literal: true

module Api
  class UsersController < ApiApplicationController
    def index
      @users = User.accessible_by(current_ability)
    end

    def show
      @user = User.find(params[:id])
      authorize! :show, @user
      @machines = @user.machines.includes(:ip).order(created_at: :asc)
    end
  end
end
