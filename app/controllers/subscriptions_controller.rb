# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :user, only: %i[new create]
  def new
    @subscription = @user.subscriptions.new
  end

  def create
    @subscription = @user.subscriptions.new(subscriptions_params)
    if @subscription.save
      user = User.find(params[:user_id])
      user.handle_new_date_end_subscription(@subscription.duration)
      user.save
      redirect_to user
    else
      render 'new'
    end
  end

  private

  def subscriptions_params
    params.require(:subscription).permit(:duration)
  end

  def user
    @user = User.find(params[:user_id])
  end
end
