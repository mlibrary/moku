# frozen_string_literal: true

require "moku/pipeline/pipeline"

module Moku
  module Pipeline

    # Set the default branch
    class SetDefaultBranch < Pipeline

      def initialize(instance:, new_branch:, instance_repo:)
        @instance = instance
        @new_branch = new_branch
        @instance_repo = instance_repo
      end

      def call
        step :set_default_branch
      end

      private

      attr_reader :instance, :new_branch, :instance_repo

      def set_default_branch
        old_branch = instance.default_branch
        instance.default_branch = new_branch
        instance_repo.save_instance(instance)
        logger.info "Changed default branch from #{old_branch} to #{new_branch}"
      end
    end

  end
end
