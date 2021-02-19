# frozen_string_literal: true

class MachinesController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  before_action :owner, only: %i[index create new]
  before_action :current_machine, only: %i[edit update destroy]

  def index
    @machines = @owner.machines
  end

  def new
    @machine = @owner.machines.new
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create
    @machine = @owner.machines.new(machine_params)
    respond_to do |format|
      ip = Ip.where(machine_id: nil).first
      if !ip.nil? && @machine.save
        @machine.ip = ip
        format.html { redirect_to @owner }
        format.json { render 'show', status: :created, location: @machine }
      else
        @machine.errors.add(:base, 'No more IPs available') if ip.nil?
        format.html { render 'new' }
        format.json { render json: @machine.errors, status: :unprocessable_entity }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def edit; end

  def update
    owner = @machine.user
    respond_to do |format|
      if @machine.update(machine_params)
        format.html { redirect_to owner }
        format.json { render 'show', status: :ok, location: @machine }
      else
        format.html { render 'edit' }
        format.json { render json: @machine.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    owner = @machine.user
    @machine.destroy
    respond_to do |format|
      format.html { redirect_to owner }
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
