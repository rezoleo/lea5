# frozen_string_literal: true

class UsersController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  def index
    @users = User.accessible_by(current_ability)
  end

  def show
    @user = User.find_by!(username: params[:username])
    authorize! :show, @user
    @machines = @user.machines.includes(:ip).order(created_at: :asc)
    @subscriptions = @user.subscriptions.order(created_at: :desc)
    @free_accesses = @user.free_accesses.order(created_at: :desc)
    @sales = @user.sales_as_client.order(created_at: :desc)
  end

  def new
    @user = User.new
    @rooms = Room.available_for(@user)
    authorize! :new, @user
  end

  def profile
    redirect_to current_user
  end

  def new_from_sso
    @user = User.new
    @rooms = Room.available_for(@user)
    authorize! :create, @user
    @query = params[:query].to_s.strip
    return if @query.blank?

    @sso_users = sso_users_service.search(query: @query)
    load_existing_users_for(@sso_users)
  rescue SsoHttpClient::RequestError => e
    render_sso_request_error(e)
  end

  def edit
    @user = User.find_by!(username: params[:username])
    @rooms = Room.available_for(@user)
    authorize! :edit, @user
  end

  def create
    @user = User.new(user_params)
    @rooms = Room.available_for(@user)
    authorize! :create, @user
    if @user.save
      flash[:success] = 'User created!'
      redirect_to @user
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def create_from_sso
    @user = User.new
    @rooms = Room.available_for(@user)
    authorize! :create, @user
    @query = sso_user_params[:query].to_s.strip
    sso_user = sso_users_service.find_by_id(user_id: sso_user_params[:oidc_id])

    return render_sso_user_not_found if sso_user.nil?

    @user = user_from_sso(sso_user)
    @rooms = Room.available_for(@user)
    return on_sso_user_created if @user.save

    @sso_users = [sso_user]
    load_existing_users_for(@sso_users)
    render 'new_from_sso', status: :unprocessable_entity
  rescue SsoHttpClient::RequestError => e
    render_sso_request_error(e)
  end

  def update
    @user = User.find_by!(username: params[:username])
    @rooms = Room.available_for(@user)
    authorize! :update, @user
    if @user.update(user_params)
      flash[:success] = 'User updated!'
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.includes(machines: :ip).find_by!(username: params[:username])
    authorize! :destroy, @user
    @user.destroy
    flash[:success] = 'User deleted!'
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :username, :room_number)
  end

  def sso_user_params
    params.permit(:query, :oidc_id, :room_number)
  end

  def sso_users_service
    @sso_users_service ||= SsoUsersService.new
  end

  def load_existing_users_for(sso_users)
    @existing_users_by_oidc_id = User.where(oidc_id: sso_users.pluck(:oidc_id)).index_by(&:oidc_id)
  end

  def user_from_sso(sso_user)
    User.new(
      firstname: sso_user[:firstname],
      lastname: sso_user[:lastname],
      email: sso_user[:email],
      username: sso_user[:username],
      oidc_id: sso_user[:oidc_id],
      room_number: sso_user_params[:room_number].presence
    )
  end

  def on_sso_user_created
    flash[:success] = 'User created from SSO!'
    redirect_to @user
  end

  def render_sso_user_not_found
    @sso_users = []
    @user.errors.add(:base, 'The selected SSO user could not be found.')
    render 'new_from_sso', status: :unprocessable_entity
  end

  def render_sso_request_error(error)
    @sso_users = []
    @user.errors.add(:base, "SSO request failed: #{error.message}")
    render 'new_from_sso', status: :unprocessable_entity
  end
end
