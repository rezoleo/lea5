# frozen_string_literal: true

module Api
  class MachinesController < ApiApplicationController
    before_action :current_machine, except: [:index, :create]
    before_action :owner, only: [:create]

    def index
      @machines = Machine.accessible_by(current_ability)
      return if params[:has_connection].blank?

      @machines = @machines.select do |machine|
        machine unless machine.user.internet_expiration.nil? || machine.user.internet_expiration < Time.current
      end
    end

    def show
      return if params[:has_connection].blank?

      @machine = nil if @machine.user.internet_expiration.nil? || @machine.user.internet_expiration < Time.current
      authorize! :show, @machine
    end

    def create
      @machine = @owner.machines.new(machine_params)
      authorize! :create, @machine
      if @machine.save
        render json: @machine, status: :created
      else
        render json: @machine.errors, status: :unprocessable_entity
      end
    end

    private

    def current_machine
      @machine = Machine.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @machine = Machine.find_by!(mac: params[:id])
    end

    def machine_params
      params.require(:machine).permit(:mac, :name)
    end

    def owner
      @owner = User.find(params[:user_id])
    end
  end
end
