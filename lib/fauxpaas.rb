require "fauxpaas/version"
require "fauxpaas/cli"
require "fauxpaas/instance"
require "fauxpaas/file_instance_repo"

module Fauxpaas

  class << self
    attr_writer :instance_root

    def root
      @root ||= Pathname.new(__FILE__).dirname.parent
    end

    def instance_repo
      @instance_repo ||= FileInstanceRepo.new(root + "deploy" + "instances")
    end

    def instance_root
      @instance_root ||= Pathname.new(__FILE__).dirname.parent.parent
    end
  end

end
