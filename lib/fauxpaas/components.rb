# frozen_string_literal: true

require "pathname"
require "fauxpaas/file_instance_repo"
require "fauxpaas/capistrano_deployer"

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

    def deployer
      @deployer ||= CapistranoDeployer.new(root + "deploy" + "capfiles")
    end

    def split_token
      @split_token ||= File.read(root + ".split_token").chomp.freeze
    end

  end

end
