# frozen_string_literal: true

# locals: (json:, user:)

json.extract! user, :id, :firstname, :lastname, :email, :room, :created_at, :updated_at
json.url user_url(user, format: :json)
json.ntlm_password CustomModules::Md4.hexdigest(user.wifi_password.encode('UTF-16LE').bytes)
