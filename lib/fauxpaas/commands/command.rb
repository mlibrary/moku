# frozen_string_literal: true

require "fauxpaas"

module Fauxpaas

  module Commands
    # Represetns a command within Fauxpaas
    class Command
      def initialize(instance_name:, user:)
        @instance_name = instance_name
        @user = user
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

      def instance
        @instance ||= Fauxpaas.instance_repo.find(instance_name)
      rescue Errno::ENOENT
        raise ArgumentError, "The requested instance [#{instance_name}] doesn't exist"
      end

      def report(status, action: "action")
        if status.success?
          Fauxpaas.logger.info "#{action} successful"
        else
          Fauxpaas.logger.fatal "#{action} failed (run again with --verbose for more info)"
        end
      end
    end

  end
end
