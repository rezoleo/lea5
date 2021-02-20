# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :user, only: %i[new create edit update destroy]
  before_action :last_subscription, only: %i[edit update destroy]

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

  def edit
    @subscription = @last_subscription
  end

  def update
    @subscription = @user.subscriptions.new(subscriptions_params)
    if @subscription.save
      @last_subscription.toggle_cancelled
      @last_subscription.save
      @user.handle_new_date_end_subscription(@subscription.duration - @last_subscription.duration)
      @user.save
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    if @user.subscriptions.count > 1
      @user.handle_new_date_end_subscription(-@last_subscription.duration)
      @last_subscription.destroy!
    elsif @user.subscriptions.count == 1
      @user.date_end_subscription = nil
      @last_subscription.destroy!
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

  def current_subscription
    @subscription = Subscription.find(params[:id])
  end

  def last_subscription
    @last_subscription = @user.subscriptions.last
    redirect_to @user unless @last_subscription
  end
end
