# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    client_options = {
      identifier: Rails.application.credentials.sso_id!,
      secret: Rails.application.credentials.sso_secret!,
      redirect_uri: "https://lea5.rezoleo.fr/#{AUTH_CALLBACK_PATH}"
    }
  elsif Rails.env.development?
    client_options = {
      identifier: Rails.application.credentials.sso_id!,
      secret: Rails.application.credentials.sso_secret!,
      redirect_uri: "http://127.0.0.1:3000/#{AUTH_CALLBACK_PATH}"
    }
  end

  # Increase security using PKCE
  # https://github.com/omniauth/omniauth_openid_connect/pull/128#issuecomment-1307489483
  # https://oauth.net/2/pkce/
  provider :openid_connect, {
    name: :keycloak,
    scope: [:openid, :email, :profile, :room, :roles],
    response_type: :code,
    issuer: 'https://auth.rezoleo.fr/realms/rezoleo',
    discovery: true,
    pkce: true,
    client_options: client_options
  }
end
