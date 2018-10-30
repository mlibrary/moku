# frozen_string_literal: true

module Fauxpaas

  module Command
    # Represetns a command within Fauxpaas
    class Command
      attr_reader :user, :logger

      def initialize(instance_name:, user:, logger: nil, instance_repo: nil)
        @instance_name = instance_name
        @user = user
        @logger = logger || Fauxpaas.logger
        @instance_repo = instance_repo || Fauxpaas.instance_repo
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

      def instance
        @instance ||= instance_repo.find(instance_name)
      rescue Errno::ENOENT
        raise ArgumentError, "The requested instance [#{instance_name}] doesn't exist"
      end

      private

      attr_reader :instance_name, :instance_repo

    end

  end
end
