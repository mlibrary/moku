# frozen_string_literal: true

module Fauxpaas
  module Pipeline

    # Pipelines represent the highest level processes that the application
    # performs. Pipelines tie everything together.
    class Pipeline
      extend Forwardable

      def_delegators :@command, :instance, :user, :logger

      def initialize(command)
        @command = command
      end

      def call
        raise NotImplementedError
      end

      private

      attr_reader :command

      def step(method)
        logger.info "Starting: #{method}"
        status = send(method)
        raise status.error if status.respond_to?(:success?) && !status.success?
      rescue StandardError => e
        logger.error "Fatal error during #{method}:\n\t#{e.message}"
      end

    end

  end
end
