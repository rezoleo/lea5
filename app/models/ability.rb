# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(entity)
    return if entity.user?

    can [:read, :update], User, id: entity.user.id
    can [:read, :update, :destroy], Machine, user: entity
    # User can create a new machine to themselves if they don't have too many machines
    can [:create], Machine do |machine|
      machine.user == entity.user && entity.machines.size < USER_MACHINES_LIMIT
    end

    can [:read], Subscription, user: entity.user
    can [:read], FreeAccess, user: entity.user

    return unless entity.user.admin? || entity.api_key?

    can :manage, :all
  end
end
