# frozen_string_literal: true

class FreeAccessesController < ApplicationController
  before_action :owner, only: %i[create new]
  before_action :current_free_access, only: %i[edit update destroy]

  def new
    @free_access = @owner.free_accesses.new
    authorize! :new, @free_access
  end

  def edit
    authorize! :edit, @free_access
  end

  def create
    @free_access = @owner.free_accesses.new(free_access_params)
    authorize! :create, @free_access
    if @free_access.save
      redirect_to @owner
    else
      render 'new'
    end
  end

  def update
    authorize! :update, @free_access
    owner = @free_access.user
    if @free_access.update(free_access_params)
      redirect_to owner
    else
      render 'edit'
    end
  end

  def destroy
    authorize! :destroy, @free_access
    owner = @free_access.user
    @free_access.destroy
    redirect_to owner
  end

  private

  def free_access_params
    params.require(:free_access).permit(:start_at, :end_at, :reason)
  end

  def owner
    @owner = User.find(params[:user_id])
  end

  def current_free_access
    @free_access = FreeAccess.find(params[:id])
  end
end
