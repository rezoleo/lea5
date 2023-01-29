# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.blank?

    can %i[read update], User, id: user.id
    can %i[read update destroy], Machine, user: user
    # User can create a new machine to themselves if they don't have too many machines
    can [:create], Machine do |machine|
      machine.user == user && user.machines.size < USER_MACHINES_LIMIT
    end

    return unless user.admin?

    can :manage, :all
  end
end
