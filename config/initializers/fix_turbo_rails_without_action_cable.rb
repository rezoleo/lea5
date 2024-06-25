# frozen_string_literal: true

# TODO: Remove this once turbo-rails releases a fix for hotwired/turbo-rails#512
# Workaround comes from https://github.com/hotwired/turbo-rails/issues/512#issuecomment-1806570740
Rails.autoloaders.once.do_not_eager_load("#{Turbo::Engine.root}/app/channels")
