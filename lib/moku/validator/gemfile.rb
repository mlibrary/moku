# frozen_string_literal: true

require "moku/validator/validator"

module Moku
  module Validator

    # Validate's an artifact's Gemfile. Specifically:
    # * If the Gemfile includes a 'ruby' directive, it should specify
    #   only a major version (e.g. 2.5).
    class Gemfile < Validator
      GEMFILE_MALFORMED = "When specifying the ruby version in the Gemfile, the" \
        " optional ruby directive must specify exactly MAJOR.MINOR version."
      GEMFILE_FORM = /^ruby (['"])[1-9]\.[0-9]+\1$/ # rubocop:disable Style/MutableConstant

      def validate
        if path.exist?
          directive = File.open(path).grep(/^ruby/)
          unless directive.empty?
            unless GEMFILE_FORM.match?(directive.first)
              add_error GEMFILE_MALFORMED
            end
          end
        end
      end

      private

      alias_method :artifact, :target

      def path
        @path ||= artifact.path/"Gemfile"
      end
    end

  end
end
