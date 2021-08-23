# frozen_string_literal: true

target :app do
  signature 'sig'

  check 'app'

  repo_path 'vendor/rbs/gem_rbs_collection/gems'

  # Ruby stdlib
  library 'date'
  library 'ipaddr'
  library 'logger'
  library 'monitor'
  library 'mutex_m'
  library 'pathname'
  library 'singleton'
  library 'time'
  library 'tsort'

  # Rails
  library 'rack'
  library 'activesupport'
  library 'actionpack'
  library 'activejob'
  library 'activemodel'
  library 'actionview'
  library 'activerecord'
  library 'railties'
end

# target :lib do
#   signature "sig"
#
#   check "lib"                       # Directory name
#   check "Gemfile"                   # File name
#   check "app/models/**/*.rb"        # Glob
#   # ignore "lib/templates/*.rb"
#
#   # library "pathname", "set"       # Standard libraries
#   # library "strong_json"           # Gems
# end

# target :spec do
#   signature "sig", "sig-private"
#
#   check "spec"
#
#   # library "pathname", "set"       # Standard libraries
#   # library "rspec"
# end
