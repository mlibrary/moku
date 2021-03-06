# frozen_string_literal: true

require "moku/pipeline/pipeline"

module Moku
  module Pipeline

    # Set the default branch
    class SetDefaultBranch < Pipeline
      register(self)

      def self.handles?(command)
        command.action == :set_default_branch
      end

      def call
        step :set_default_branch
      end

      private

      def new_branch
        command.new_branch
      end

      def instance_repo
        command.instance_repo
      end

      def set_default_branch
        old_branch = instance.default_branch
        instance.default_branch = new_branch
        instance_repo.save_instance(instance)
        logger.info "Changed default branch from #{old_branch} to #{new_branch}"
      end
    end

  end
end
