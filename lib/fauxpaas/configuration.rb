require "ostruct"
require "pathname"
require "fauxpaas/file_instance_repo"
require "fauxpaas/capistrano_deployer"

module Fauxpaas
  class Configuration < OpenStruct
    def merge(other)
      Configuration.new(self.to_h.merge(other.to_h))
    end
    def gem_root
      @lib_root ||= Pathname.new(__FILE__).dirname.parent.parent
    end

    def instance_root
      @instance_root ||= gem_root + "deploy" + "instances"
    end

    def instance_repo
      @instance_repo ||= FileInstanceRepo.new(instance_root)
    end

    def deployer
      @deployer ||= CapistranoDeployer.new(gem_root + "deploy" + "capfiles")
    end

    def split_token
      @split_token ||= File.read(gem_root + ".split_token").chomp.freeze
    end
  end

  def self.config=(value)
    @config = value
  end

  def self.config
    @config ||= Configuration.new
  end

  # Avoid having to type Fauxpaas.config.thing_i_want by
  # delegating here.
  def self.method_missing(method, *args)
    if config.respond_to?(method)
      config.send(method, *args)
    else
      super
    end
  end
end
