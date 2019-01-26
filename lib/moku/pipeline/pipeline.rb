# frozen_string_literal: true

module Moku
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
        begin
          logger.info "Starting: #{method}"
          status = send(method)
        rescue StandardError => e
          logger.error "Fatal error during #{method}: #{e.message}\n" \
            "\t#{e.backtrace.join("\n\t")}"
          raise
        end
        if status.respond_to?(:success?) && !status.success?
          raise status.error
        end
      end

    end

  end
end
