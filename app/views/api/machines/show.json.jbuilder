# frozen_string_literal: true

# locals: ()

json.partial! 'api/machines/machine', machine: @machine
json.user @machine.user, partial: 'api/users/user', as: :user
