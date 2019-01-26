# frozen_string_literal: true

require "moku"
require "moku/command/command"

module Moku
  module Command

    # Change the instance's default source branch
    class SetDefaultBranch < Command
      def initialize(instance_name:, user:, new_branch:)
        super(instance_name: instance_name, user: user)
        @new_branch = new_branch
      end

      attr_reader :new_branch

      def action
        :set_default_branch
      end

      def instance_repo
        Moku.instance_repo
      end

    end

  end
end
