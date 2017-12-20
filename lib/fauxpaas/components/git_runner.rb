# frozen_string_literal: true

require "fauxpaas/components/system_runner"
require "fauxpaas/git_runner"
require "fauxpaas/local_git_resolver"
require "fauxpaas/remote_git_resolver"

module Fauxpaas
  class << self
    def git_runner
      @git_runner ||= GitRunner.new(
        local_resolver: LocalGitResolver.new(system_runner),
        remote_resolver: RemoteGitResolver.new(system_runner),
        system_runner: system_runner
      )
    end

    attr_writer :git_runner
  end
end
