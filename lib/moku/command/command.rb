# frozen_string_literal: true

require "moku/pipeline"

module Moku

  module Command
    # Represents a command within Moku
    class Command
      attr_reader :user

      def initialize(instance_name:, user:, instance_repo: nil)
        @instance_name = instance_name
        @user = user || "nobody"
        @instance_repo = instance_repo || Moku.instance_repo
      end

      def call
        raise NotImplementedError
      end

      def action
        :none
      end

      def instance
        @instance ||= instance_repo.find(instance_name)
      rescue Errno::ENOENT
        raise ArgumentError, "The requested instance [#{instance_name}] doesn't exist"
      end

      private

      attr_reader :instance_repo, :instance_name

      def logger
        Moku.logger
      end

    end

  end
end
