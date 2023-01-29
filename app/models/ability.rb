# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.blank?

    can %i[read update], User, id: user.id

    return unless user.admin?

    can :manage, :all
  end
end
