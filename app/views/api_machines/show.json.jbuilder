# frozen_string_literal: true

# locals: ()

json.partial! 'machines/machine', machine: @machine
json.user @machine.user, partial: 'users/user', as: :user
