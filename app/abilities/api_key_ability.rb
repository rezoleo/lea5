# frozen_string_literal: true

class ApiKeyAbility
  include CanCan::Ability

  def initialize(api_key)
    return if api_key.blank?

    can :read, :all
    can :create, Machine
  end
end
