# frozen_string_literal: true

class UsersController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  def index
    @users = User.accessible_by(current_ability)
  end

  def show
    @user = User.includes(machines: :ip).find(params[:id])
    authorize! :show, @user
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
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user }
        format.json { render 'show', status: :created, location: @user }
      else
        format.html { render 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @user = User.find(params[:id])
    authorize! :update, @user
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user }
        format.json { render 'show', status: :ok, location: @user }
      else
        format.html { render 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.includes(machines: :ip).find(params[:id])
    authorize! :destroy, @user
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :room)
  end
end
