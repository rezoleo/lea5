# frozen_string_literal: true

module Overcommit::Hook::PreCommit # rubocop:disable Style/ClassAndModuleChildren
  class EnsureStrictLocals < Base
    def run
      messages = []

      applicable_files.each do |file|
        content = File.read(file)

        case File.extname(file)
        when '.erb'
          messages << error_message(:error, file, 'missing `<%# locals: () %>`') unless content.include?('<%# locals:')
        when '.jbuilder'
          messages << error_message(:error, file, 'missing `# locals: ()`') unless content.include?('# locals:')
        else
          messages << error_message(:warning, file, 'unknown file extension')
        end
      end

      messages
    end

    private

    def error_message(type, file, message)
      Overcommit::Hook::Message.new(
        type,
        file,
        1,
        "#{file}:1: #{message}"
      )
    end
  end
end
