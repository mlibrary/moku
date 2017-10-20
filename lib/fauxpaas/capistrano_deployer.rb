require "pathname"
require "open3"

module Fauxpaas

  class CapistranoDeployer
    def initialize(capfile_path, kernel = Open3)
      @capfile_path = Pathname.new capfile_path
      @kernel = kernel
    end

    def deploy(instance,branch: 'master')
      instance_capfile_path = capfile_path + "#{instance.deployer_env}.capfile"
      stdout, stderr, status = kernel.capture3(
        "cap -f #{instance_capfile_path} #{instance.name} deploy BRANCH=#{branch}"
      )
      return status
    end

    def caches(instance)
      instance_capfile_path = capfile_path + "#{instance.deployer_env}.capfile"
      stdout, stderr, status = kernel.capture3(
        "cap -f #{instance_capfile_path} #{instance.name} caches:list"
      )
      stderr
        .split(Fauxpaas.split_token + "\n")
        .drop(1)
        .map{|dirs| dirs.split("\n")}
        .first
    end

    private
    attr_reader :capfile_path, :kernel

  end

end
