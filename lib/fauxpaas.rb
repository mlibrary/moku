require "fauxpaas/version"
require "fauxpaas/cli"
require "fauxpaas/instance"
require "fauxpaas/file_instance_repo"
require "fauxpaas/capistrano_deployer"

module Fauxpaas

  class << self

    def root
      @root ||= Pathname.new(__FILE__).dirname.parent
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

  end

end
