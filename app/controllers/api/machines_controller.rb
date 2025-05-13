# frozen_string_literal: true

module Api
  class MachinesController < ApiApplicationController
    before_action :current_machine

    def show
      authorize! :show, @machine
    end

    private

    def current_machine
      @machine = Machine.find(params[:id])
    end
  end
end
