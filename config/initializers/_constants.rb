# frozen_string_literal: true

# Path to login via api key
API_PATH = 'api'

# Path to login via SSO authentication
AUTH_PATH = '/auth/oidc'

# Callback path from SSO authentication
AUTH_CALLBACK_PATH = "#{AUTH_PATH}/callback".freeze

SESSION_DURATION_TIME = 3.hours

# The number of machines a user can create on their own
USER_MACHINES_LIMIT = 4
