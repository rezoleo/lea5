# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/CyclomaticComplexity
# frozen_string_literal: true

require 'active_support/core_ext/string' # String.underscore

module CustomCops
  class InheritsApiApplicationController < RuboCop::Cop::Base
    MOD_DIRECTORY = 'app/controllers/api/'
    MOD_CONTROLLER = 'ApiApplicationController'
    MSG = "All controllers in the Mod namespace should inherit from #{MOD_CONTROLLER}" # rubocop:disable Style/MutableConstant

    def on_class(node)
      rel_path = RuboCop::PathUtil.relative_path(filename(node))
      return unless rel_path.start_with?(MOD_DIRECTORY)

      class_name = node.identifier.const_name
      return if class_name == MOD_CONTROLLER
      return unless rel_path.end_with?("#{class_name.underscore}.rb")

      parent_module_name = node.parent_module_name
      full_class_name = case parent_module_name
                        when 'Object', ''
                          class_name
                        else
                          "#{parent_module_name}::#{class_name}"
                        end
      return if full_class_name == MOD_CONTROLLER

      parent_class = node.parent_class&.const_name || ''

      if parent_class == MOD_CONTROLLER ||
         (parent_module_name.split('::').include?('Mod') && "Mod::#{parent_class}" == MOD_CONTROLLER)
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
