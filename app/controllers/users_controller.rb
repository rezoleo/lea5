# frozen_string_literal: true

class UsersController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

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

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
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
    User.find(params[:id]).destroy
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :room)
  end
end
