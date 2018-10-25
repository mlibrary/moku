# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/command/command"

module Fauxpaas
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
        Fauxpaas.instance_repo
      end

    end

  end
end
