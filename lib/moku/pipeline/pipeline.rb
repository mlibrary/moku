# frozen_string_literal: true

module Moku
  module Pipeline

    # Pipelines represent the highest level processes that the application
    # performs. Pipelines tie everything together.
    class Pipeline

      # Allows for injection of the logger in tests.
      attr_writer :logger

      def logger
        @logger ||= Moku.logger
      end

      def call
        logger.error "Unrecognized command"
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
        raise status.error if status.respond_to?(:success?) && !status.success?
      end

    end

  end
end
