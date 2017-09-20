require "fauxpaas/version"
require "fauxpaas/cli"
require "fauxpaas/instance"

module Fauxpaas

  class << self
    attr_writer :instance_root
    def instance_root
      @instance_root ||= Pathname.new(__FILE__).dirname.parent.parent
    end
  end

end
