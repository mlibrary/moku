# frozen_string_literal: true

require "fauxpaas"
require "fauxpaas/commands/command"

module Fauxpaas
  module Commands

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

      def execute
        old_branch = instance.default_branch
        instance.default_branch = new_branch
        Fauxpaas.instance_repo.save_instance(instance)
        Fauxpaas.logger.info "Changed default branch from #{old_branch} to #{new_branch}"
      end
    end

  end
end
