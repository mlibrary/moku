# frozen_string_literal: true

require "moku/task/task"
require "moku/status"
require "moku/validator/gemfile"
require "moku/validator/puma"
require "moku/validator/ruby_version"

module Moku
  module Task

    # Validates that the project correctly specifies its ruby version
    # * There is a .ruby-version present
    # * It specifies only a major version (e.g. 2.5)
    # * If the Gemfile includes a 'ruby' directive, it should specify only a major version.
    class ValidatePin

      def initialize
        @errors = []
      end

      # @param artifact [Artifact]
      # @return [Status]
      def call(artifact)
        @errors += Validator::Gemfile.new(artifact).errors
        @errors += Validator::Puma.new(artifact).errors
        @errors += Validator::RubyVersion.new(artifact).errors
        if errors.empty?
          Status.success
        else
          Status.failure(errors.join("\n"))
        end
      end

      private

      attr_reader :errors

    end

  end
end
