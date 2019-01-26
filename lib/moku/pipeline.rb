# frozen_string_literal: true

require "moku/pipeline/caches"
require "moku/pipeline/deploy"
require "moku/pipeline/read_default_branch"
require "moku/pipeline/releases"
require "moku/pipeline/rollback"
require "moku/pipeline/set_default_branch"

module Moku

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
