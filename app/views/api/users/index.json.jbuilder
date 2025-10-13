# frozen_string_literal: true

# locals: ()

json.array! @users, partial: 'api/users/user', as: :user
