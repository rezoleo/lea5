# frozen_string_literal: true

module Api
  class MachinesController < ApiApplicationController
    before_action :current_machine, except: [:index, :create]
    before_action :owner, only: [:create]

    def index
      @machines = Machine.accessible_by(current_ability)
    end

    def show
      authorize! :show, @machine
    end

    def create
      @machine = @owner.machines.new(machine_params)
      authorize! :create, @machine
      if @machine.save!
        render json: 'show', status: :created, location: @machine
      else
        render json: @machine.errors, status: :unprocessable_entity
      end
    end

    private

    def current_machine
      @machine = Machine.find(params[:id])
    end

    def machine_params
      params.require(:machine).permit(:mac, :name)
    end

    def owner
      @owner = User.find(params[:user_id])
    end
  end
end
