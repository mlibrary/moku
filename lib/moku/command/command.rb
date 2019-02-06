# frozen_string_literal: true

module Moku

  module Command
    # Represetns a command within Moku
    class Command
      attr_reader :user, :logger, :instance_name

      def initialize(instance_name:, user:, logger: nil, instance_repo: nil)
        @instance_name = instance_name
        @user = user
        @logger = logger || Moku.logger
        @instance_repo = instance_repo || Moku.instance_repo
      end

      def action
        :none
      end

      def authorized?
        Moku.auth.authorized?(
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

      attr_reader :instance_repo

    end

  end
end
