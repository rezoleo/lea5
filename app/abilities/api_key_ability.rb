# frozen_string_literal: true

class ApiKeyAbility
  include CanCan::Ability
  def initialize(api_key) # rubocop:disable Lint/UnusedMethodArgument
    can :read, :all
  end
end
