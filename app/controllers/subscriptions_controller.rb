# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :user, only: %i[new create destroy]

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

  def destroy
    if @user.subscriptions.count > 1
      last_subscription = @user.subscriptions.last
      @user.handle_new_date_end_subscription(-last_subscription.duration)
      last_subscription.destroy!
    elsif @user.subscriptions.count == 1
      @user.subscriptions.last.destroy!
      @user.date_end_subscription = nil
    end
    @user.save
    redirect_to @user
  end

  private

  def subscriptions_params
    params.require(:subscription).permit(:duration)
  end

  def user
    @user = User.find(params[:user_id])
  end
end
