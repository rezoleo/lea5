# frozen_string_literal: true

# locals: ()

json.array! @users, partial: 'users/user', as: :user
