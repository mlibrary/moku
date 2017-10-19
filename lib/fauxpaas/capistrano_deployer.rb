require "pathname"

module Fauxpaas

  class CapistranoDeployer
    def initialize(capfile_path, kernel = Kernel)
      @capfile_path = Pathname.new capfile_path
      @kernel = kernel
    end

    def deploy(instance, reference: nil)
      instance_capfile_path = capfile_path + "#{instance.deployer_env}.capfile"
      kernel.system("cap -f #{instance_capfile_path} #{instance.name} deploy BRANCH=#{reference || instance.default_branch}")
    end

    private
    attr_reader :capfile_path, :kernel

  end

end
