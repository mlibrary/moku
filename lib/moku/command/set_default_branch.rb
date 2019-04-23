# frozen_string_literal: true

require "moku"
require "moku/command/command"
require "moku/pipeline/set_default_branch"

module Moku
  module Command

    # Change the instance's default source branch
    class SetDefaultBranch < Command
      def initialize(instance_name:, user:, new_branch:)
        super(instance_name: instance_name, user: user)
        @new_branch = new_branch
      end

      def action
        :set_default_branch
      end

      def call
        Pipeline::SetDefaultBranch.new(
          instance: instance,
          new_branch: new_branch,
          instance_repo: instance_repo
        ).call
      end

      private
      attr_reader :new_branch

      def instance_repo
        Moku.instance_repo
      end

    end

  end
end
