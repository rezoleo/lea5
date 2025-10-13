# frozen_string_literal: true

class MachinesController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  before_action :owner, only: [:create, :new]
  before_action :current_machine, only: [:show, :edit, :update, :destroy]

  def show
    authorize! :show, @machine
  end

  def new
    @machine = @owner.machines.new
    authorize! :new, @machine
  end

  def edit
    authorize! :edit, @machine
  end

  def create
    @machine = @owner.machines.new(machine_params)
    authorize! :create, @machine
    if @machine.save
      flash[:success] = 'Machine added!'
      redirect_to @owner
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def update
    authorize! :update, @machine
    owner = @machine.user
    if @machine.update(machine_params)
      flash[:success] = 'Machine updated!'
      redirect_to owner
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @machine
    owner = @machine.user
    @machine.destroy
    flash[:success] = 'Machine deleted!'
    redirect_to owner
  end

  private

  def machine_params
    params.require(:machine).permit(:mac, :name)
  end

  def owner
    @owner = User.find(params[:user_id])
  end

  def current_machine
    @machine = Machine.find(params[:id])
  end
end
