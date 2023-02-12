# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :owner, only: %i[create new]
  before_action :current_subscription, only: %i[destroy]

  def new
    @subscription = @owner.subscriptions.new
    authorize! :new, @subscription
  end

  def create
    @subscription = @owner.extend_subscription(duration: Integer(subscription_params[:duration]))
    authorize! :create, @subscription
    if @subscription.save
      redirect_to @owner
    else
      render 'new'
    end
  end

  def destroy
    authorize! :destroy, @subscription
    owner = @subscription.user
    owner.cancel_current_subscription!
    redirect_to owner
  end

  private

  def subscription_params
    params.require(:subscription).permit(:duration)
  end

  def owner
    @owner = User.find(params[:user_id])
  end

  def current_subscription
    @subscription = Subscription.find(params[:id])
  end
end
