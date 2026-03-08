# frozen_string_literal: true

class UsersController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  def index
    @users = User.accessible_by(current_ability)
  end

  def show
    @user = User.find(params[:id])
    authorize! :show, @user
    @machines = @user.machines.includes(:ip).order(created_at: :asc)
    @subscriptions = @user.subscriptions.order(created_at: :desc)
    @free_accesses = @user.free_accesses.order(created_at: :desc)
    @sales = @user.sales_as_client.order(created_at: :desc)
  end

  def new
    @user = User.new
    authorize! :new, @user
  end

  def edit
    @user = User.find(params[:id])
    authorize! :edit, @user
  end

  def create
    @user = User.new(user_params)
    authorize! :create, @user
    if @user.save
      flash[:success] = 'User created!'
      redirect_to @user
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])
    authorize! :update, @user
    if @user.update(user_params)
      flash[:success] = 'User updated!'
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.includes(machines: :ip).find(params[:id])
    authorize! :destroy, @user
    @user.destroy
    flash[:success] = 'User deleted!'
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :room, :username)
  end
end
