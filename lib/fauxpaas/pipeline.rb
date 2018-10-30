# frozen_string_literal: true

require "fauxpaas/pipeline/caches"
require "fauxpaas/pipeline/deploy"
require "fauxpaas/pipeline/read_default_branch"
require "fauxpaas/pipeline/releases"
require "fauxpaas/pipeline/rollback"
require "fauxpaas/pipeline/set_default_branch"

module Fauxpaas

  # Namespace and factory for pipelines
  module Pipeline
    def self.for(command)
      case command.action
      when :caches
        Caches
      when :deploy
        Deploy
      when :read_default_branch
        ReadDefaultBranch
      when :releases
        Releases
      when :rollback
        Rollback
      when :set_default_branch
        SetDefaultBranch
      else
        raise "Unrecognized command: #{command.action}"
      end.new(command)
    end

  end
end
