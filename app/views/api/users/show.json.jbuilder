# frozen_string_literal: true

# locals: ()

json.partial! 'api/users/user', user: @user
json.ntlm_password @ntlm_password
