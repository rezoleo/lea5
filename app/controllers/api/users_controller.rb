# frozen_string_literal: true

module Api
  class UsersController < ApiApplicationController
    def index
      @users = User.accessible_by(current_ability)
    end

    def show
      begin
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @user = User.find_by!(username: params[:id])
      end
      authorize! :show, @user
      @machines = @user.machines.includes(:ip).order(created_at: :asc)
      openssl_legacy_provider = OpenSSL::Provider.load('legacy')
      @ntlm_password = OpenSSL::Digest::MD4.hexdigest(@user.wifi_password.encode('utf-16le'))
      openssl_legacy_provider.unload
    end
  end
end
