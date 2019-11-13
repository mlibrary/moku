# frozen_string_literal: true

require "moku/validator/validator"
require "bundler"

module Moku
  module Validator

    # Validate that the Gemfile includes puma of an appropriate version
    # and in the production/default group.
    class Puma < Validator

      # A null object implementation of a resolved bundler version
      class NotFound
        def satisifies?(_)
          false
        end
      end

      PUMA_ERROR = "Ruby projects must contain puma. Please specify a puma in your" \
        " Gemfile. The version must be #{Moku.puma_requirement}"

      def validate
        if gemfile.exist? && gemfile_lock.exist?
          unless puma_version.satisfies?(requirement)
            add_error PUMA_ERROR
          end
        end
      end

      private

      alias_method :artifact, :target

      def check_gems; end

      def definition
        Bundler::Definition.build(gemfile, gemfile_lock, {})
      end

      def puma_version
        definition.resolve["puma"].first || NotFound.new
      end

      def requirement
        Bundler::Dependency.new("puma", Moku.puma_requirement)
      end

      def gemfile
        @gemfile ||= artifact.path/"Gemfile"
      end

      def gemfile_lock
        @gemfile_lock ||= artifact.path/"Gemfile.lock"
      end
    end

  end
end
