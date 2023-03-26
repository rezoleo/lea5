# frozen_string_literal: true

class MachinesController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  before_action :owner, only: %i[create new]
  before_action :current_machine, only: %i[show edit update destroy]

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
    respond_to do |format|
      if @machine.save
        format.html do
          flash[:success] = 'Machine added!'
          redirect_to @owner
        end
        format.json { render 'show', status: :created, location: @machine }
      else
        format.html { render 'new', status: :unprocessable_entity }
        format.json { render json: @machine.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! :update, @machine
    owner = @machine.user
    respond_to do |format|
      if @machine.update(machine_params)
        format.html do
          flash[:success] = 'Machine updated!'
          redirect_to owner
        end
        format.json { render 'show', status: :ok, location: @machine }
      else
        format.html { render 'edit', status: :unprocessable_entity }
        format.json { render json: @machine.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! :destroy, @machine
    owner = @machine.user
    @machine.destroy
    respond_to do |format|
      format.html do
        flash[:success] = 'Machine deleted!'
        redirect_to owner
      end
      format.json { head :no_content }
    end
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
