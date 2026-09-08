# frozen_string_literal: true

module Api
  class MachinesController < ApiApplicationController
    before_action :current_machine, except: [:index, :create]
    before_action :owner, only: [:create]

    def index
      machines = Machine.accessible_by(current_ability)
                        .includes(:ip, user: [:valid_subscriptions_by_date, :free_accesses_by_date])
                        .order(:id)
      machines = machines.with_internet_access if ActiveModel::Type::Boolean.new.cast(params[:with_internet_access])

      @machines = paginate(machines)
    end

    def show
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
