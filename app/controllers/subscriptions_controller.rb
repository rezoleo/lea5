# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  before_action :user, only: %i[new create destroy]
  before_action :last_subscription, only: %i[destroy]

  def index
    @subscriptions = Subscription.all
  end

  def new
    @subscription = @user.subscriptions.new
  end

  def create
    @subscription = @user.add_subscription(subscription_params)
    respond_to do |format|
      if @subscription.save
        format.html { redirect_to @user }
        format.json { render 'show', status: :created }
      else
        format.html { render 'new' }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.cancel_subscription(@last_subscription)
    respond_to do |format|
      format.html { redirect_to @user }
      format.json { head :no_content }
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:duration)
  end

  def user
    @user = User.find(params[:user_id])
  end

  def last_subscription
    @last_subscription = @user.subscriptions.not_cancelled.last
    return if @last_subscription

    respond_to do |format|
      format.html { redirect_to @user }
      format.json { render json: { error: 'There is no subscription' }, status: :unprocessable_entity }
    end
  end
end
