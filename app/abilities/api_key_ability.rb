# frozen_string_literal: true

class ApiKeyAbility
  include CanCan::Ability

  def initialize(api_key)
    return if api_key.blank?

    can :read, :all
    can [:create], Machine do |machine|
      machine.user.machines.size <= USER_MACHINES_LIMIT
    end
  end
end
