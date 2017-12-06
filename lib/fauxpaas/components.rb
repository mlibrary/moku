# frozen_string_literal: true

require "pathname"
require "fauxpaas/file_instance_repo"
require "fauxpaas/open3_capture"
require "fauxpaas/cap_runner"
require "fauxpaas/git_runner"
require "fauxpaas/local_git_resolver"
require "fauxpaas/remote_git_resolver"

# Fake Platform As A Service
module Fauxpaas

  class << self

    def root
      @root ||= Pathname.new(__FILE__).dirname.parent.parent
    end

    def instance_repo
      @instance_repo ||= FileInstanceRepo.new(instance_root)
    end

    def instance_root
      @instance_root ||= root + "deploy" + "instances"
    end

    def deployer_env_root
      @deployer_env_root ||= root + "deploy" + "capfiles"
    end

    def system_runner
      @system_runner ||= Open3Capture.new
    end

    def git_runner
      @git_runner ||= GitRunner.new(
        local_resolver: LocalGitResolver.new(system_runner),
        remote_resolver: RemoteGitResolver.new(system_runner),
        system_runner: system_runner
      )
    end

    def backend_runner
      @backend_runner ||= CapRunner.new(system_runner)
    end

    def split_token
      @split_token ||= File.read(root + ".split_token").chomp.freeze
    end

    attr_writer :system_runner, :instance_repo, :git_runner

  end

end
