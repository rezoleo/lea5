# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :owner, only: %i[create new destroy]

  def new
    @subscription = @owner.subscriptions.new
    authorize! :new, @subscription
  end

  def create
    @subscription = @owner.extend_subscription(duration: Integer(subscription_params[:duration]))
    authorize! :create, @subscription
    if @subscription.save
      flash[:success] = 'New subscription added!'
      redirect_to @owner
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @owner.current_subscription
    owner.cancel_current_subscription!
    flash[:success] = 'Last subscription cancelled!'
    redirect_to owner
  end

  private

  def subscription_params
    params.require(:subscription).permit(:duration)
  end

  def owner
    @owner = User.find(params[:user_id])
  end
end
