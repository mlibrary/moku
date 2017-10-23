require "pathname"
require "open3"

module Fauxpaas

  class CapistranoDeployer
    def initialize(capfile_path, kernel = Open3)
      @capfile_path = Pathname.new capfile_path
      @kernel = kernel
    end

    def deploy(instance, reference: nil)
      instance_capfile_path = capfile_path + "#{instance.deployer_env}.capfile"
      stdout, stderr, status = kernel.capture3(
        "cap -f #{instance_capfile_path} #{instance.name} deploy BRANCH=#{reference || instance.default_branch}"
      )
      return status
    end

    def rollback(instance, cache: nil)
      instance_capfile_path = capfile_path + "#{instance.deployer_env}.capfile"
      stdout, stderr, status = kernel.capture3(
        "cap -f #{instance_capfile_path} #{instance.name} deploy:rollback #{rollback_cache_option(cache)}".strip
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

    def rollback_cache_option(cache)
      if cache
        "ROLLBACK_RELEASE=#{cache}"
      else
        ""
      end
    end

  end

end
