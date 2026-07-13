# frozen_string_literal: true

require 'openssl'

# FreeRADIUS integration needs the NTLM (MD4) hash of the stored Wi-Fi password.
# MD4 lives in OpenSSL 3's "legacy" provider. Loading it once at boot instead of
# per-request: OpenSSL::Provider.load/unload mutate process-global state and are
# not safe to toggle from multiple Puma threads concurrently.

# NOTE: explicitly loading a provider can stop OpenSSL from auto-activating the
# "default" provider, so load it as well to be safe.
OpenSSL::Provider.load('default')
OpenSSL::Provider.load('legacy')
