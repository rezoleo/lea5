# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.blank?

    can [:read, :update], User, id: user.id
    can [:read, :update, :destroy], Machine, user: user
    # User can create a new machine to themselves if they don't have too many machines
    can [:create], Machine do |machine|
      machine.user == user && user.machines.size < USER_MACHINES_LIMIT
    end

    can [:read], Subscription, user: user
    can [:read], Sale, user: user
    can [:read], Refund, user: user
    can [:read], FreeAccess, user: user

    return unless user.admin?

    can :manage, :all
  end
end
