# frozen_string_literal: true

module Moku
  module Pipeline

    # Pipelines represent the highest level processes that the application
    # performs. Pipelines tie everything together.
    class Pipeline
      extend Forwardable

      def self.for(target)
        registry.find {|candidate| candidate.handles?(target) }
          .new(target)
      end

      def self.registry
        @@registry ||= []
      end

      def self.register(candidate)
        registry.unshift(candidate)
      end

      def self.handles?(command)
        true
      end

      # Register ourself as a default
      register(self)

      def_delegators :@command, :instance, :user, :logger

      def initialize(command)
        @command = command
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
        if status.respond_to?(:success?) && !status.success?
          raise status.error
        end
      end

    end

  end
end
