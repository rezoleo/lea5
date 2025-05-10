# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/CyclomaticComplexity
# frozen_string_literal: true

# The vast majority of this code has been taken from Lobsters Rails Project : https://github.com/lobsters/lobsters

# :nocov:

require 'active_support/core_ext/string' # String.underscore
require 'rubocop'

module CustomCops
  class InheritsApiApplicationController < RuboCop::Cop::Base
    API_DIRECTORY = 'app/controllers/api/'
    API_CONTROLLER = 'ApiApplicationController'
    MSG = "All controllers in the Api namespace should inherit from #{API_CONTROLLER}".freeze

    def on_class(node)
      rel_path = RuboCop::PathUtil.relative_path(filename(node))
      return unless rel_path.start_with?(API_DIRECTORY)

      class_name = node.identifier.const_name
      return if class_name == API_CONTROLLER
      return unless rel_path.end_with?("#{class_name.underscore}.rb")

      parent_module_name = node.parent_module_name
      full_class_name = case parent_module_name
                        when 'Object', ''
                          class_name
                        else
                          "#{parent_module_name}::#{class_name}"
                        end
      return if full_class_name == API_CONTROLLER

      parent_class = node.parent_class&.const_name || ''

      if parent_class == API_CONTROLLER ||
         (parent_module_name.split('::').include?('Api') && "Api::#{parent_class}" == API_CONTROLLER)
        return
      end

      add_offense(node)
    end

    def filename(node)
      node.location.expression.source_buffer.name
    end
  end
end
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity

# :nocov:
