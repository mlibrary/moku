# frozen_string_literal: true

require "fauxpaas/pipeline/deploy"
require "fauxpaas/pipeline/read_default_branch"
require "fauxpaas/pipeline/releases"
require "fauxpaas/pipeline/set_default_branch"

module Fauxpaas

  # Namespace and factory for pipelines
  module Pipeline
    def self.for(command)
      case command.action
      when :deploy
        Deploy
      when :set_default_branch
        SetDefaultBranch
      when :read_default_branch
        ReadDefaultBranch
      when :releases
        Releases
      else
        raise "Unrecognized command: #{command.action}"
      end.new(command)
    end

  end
end
