# frozen_string_literal: true

module Fauxpaas

  module Command
    # Represetns a command within Fauxpaas
    class Command
      def initialize(instance_name:, user:, logger: nil, instance_repo: nil)
        @instance_name = instance_name
        @user = user
        @logger = logger || Fauxpaas.logger
        @instance_repo = instance_repo || Fauxpaas.instance_repo
      end

      def execute
        raise NotImplementedError
      end

      def action
        :none
      end

      def authorized?
        Fauxpaas.auth.authorized?(
          user: user || "nobody",
          entity: instance,
          action: action
        )
      end

      private

      attr_reader :instance_name, :user
      attr_reader :logger, :instance_repo

      def instance
        @instance ||= instance_repo.find(instance_name)
      rescue Errno::ENOENT
        raise ArgumentError, "The requested instance [#{instance_name}] doesn't exist"
      end

      def report(status, action: "action")
        if status.success?
          logger.info "#{action} successful"
        else
          logger.fatal "#{action} failed (run again with --verbose for more info)"
        end
      end
    end

  end
end
