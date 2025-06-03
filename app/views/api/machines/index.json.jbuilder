# frozen_string_literal: true

# locals: ()

json.array!(@machines) do |machine|
  json.partial! 'api/machines/machine', machine: machine
  json.user machine.user, partial: 'api/users/user', as: :user
end
