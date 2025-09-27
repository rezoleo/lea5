# frozen_string_literal: true

# locals: ()

json.partial! 'api/users/user', user: @user
openssl_legacy_provider = OpenSSL::Provider.load('legacy')
json.ntlm_password OpenSSL::Digest::MD4.hexdigest(@user.wifi_password.encode('utf-16le'))
openssl_legacy_provider.unload
