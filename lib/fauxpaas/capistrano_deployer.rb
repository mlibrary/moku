require "pathname"

module Fauxpaas

  class CapistranoDeployer
    def initialize(capfile_path, kernel = Kernel)
      @capfile_path = Pathname.new capfile_path
      @kernel = kernel
    end

    def deploy(instance)
      instance_capfile_path = capfile_path + "#{instance.deployer_env}.capfile"
      kernel.system("cap -f #{instance_capfile_path} #{instance.name} deploy")
    end

    private
    attr_reader :capfile_path, :kernel

  end

end
