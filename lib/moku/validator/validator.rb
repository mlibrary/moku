# frozen_string_literal: true

module Moku
  module Validator

    # Perform a set of validations on an artifact or release
    class Validator
      def initialize(target)
        @target = target
        @errors = []
      end

      def errors
        validate
        @errors
      end

      def valid?
        validate
        errors.empty?
      end

      private

      attr_reader :target
    end

  end
end
