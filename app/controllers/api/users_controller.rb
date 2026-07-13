# frozen_string_literal: true

module Api
  class UsersController < ApiApplicationController
    def index
      @users = User.accessible_by(current_ability).includes(:valid_subscriptions_by_date, :free_accesses_by_date)
    end

    def show
      @user = User.find_by!(username: params[:username])
      authorize! :show, @user
      @machines = @user.machines.includes(:ip).order(created_at: :asc)
      @ntlm_password = @user.ntlm_password
    end
  end
end
