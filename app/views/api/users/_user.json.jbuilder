# frozen_string_literal: true

# locals: (json:, user:)

json.extract! user, :id, :firstname, :lastname, :pseudo, :email, :room, :created_at, :updated_at
json.url api_user_url(user)
json.ntlm_password CustomModules::Md4.hexdigest(user.wifi_password.encode('UTF-16LE').bytes)
json.internet_expiration user.internet_expiration
