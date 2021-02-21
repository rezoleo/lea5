# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :user, only: %i[new create destroy]
  before_action :last_subscription, only: %i[destroy]

  def index
    @subscriptions = Subscription.all
  end

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
      @user.handle_new_date_end_subscription(-@last_subscription.duration)
    else
      @user.date_end_subscription = nil
    end
    @last_subscription.destroy!
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

  def last_subscription
    @last_subscription = @user.subscriptions.last
    redirect_to @user unless @last_subscription
  end
end
