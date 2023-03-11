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
  provider :openid_connect, {
    name: :keycloak,
    scope: %i[openid email profile room roles],
    response_type: :code,
    issuer: 'https://auth.rezoleo.fr/realms/rezoleo',
    discovery: true,
    client_options:
  }
end
