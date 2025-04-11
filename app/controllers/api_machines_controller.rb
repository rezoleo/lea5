# frozen_string_literal: true

class ApiMachinesController < ApiApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  before_action :current_machine

  def show
    authorize! :show, @machine
  end

  private

  def current_machine
    @machine = Machine.find(params[:id])
  end
end
