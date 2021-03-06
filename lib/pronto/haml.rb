require 'pronto'
require 'haml_lint'

module Pronto
  class Haml < Runner
    def initialize
      @runner = ::HamlLint::Runner.new
    end

    def run(patches, _)
      return [] unless patches

      patches.select { |patch| patch.additions > 0 }
        .select { |patch| haml_file?(patch.new_file_full_path) }
        .map { |patch| inspect(patch) }
        .flatten.compact
    end

    def inspect(patch)
      lints = @runner.run(files: [patch.new_file_full_path.to_s]).lints
      lints.map do |lint|
        patch.added_lines.select { |line| line.new_lineno == lint.line }
          .map { |line| new_message(lint, line) }
      end
    end

    def new_message(lint, line)
      path = line.patch.delta.new_file[:path]
      Message.new(path, line, lint.severity, lint.message)
    end

    private

    def haml_file?(path)
      File.extname(path) == '.haml'
    end
  end
end
