require "pathname"
require "fauxpaas/var_file"

module Fauxpaas

  # Represents a named instance within fauxpaas, as opposed
  # to installed on destination servers.
  class Instance
    attr_reader :app, :stage

    def initialize(name)
      @app, @stage = name.split("-")
    end

    def var_file
      VarFile.new(path + "fauxpaas.yml")
    end

    def path
      Fauxpaas.instance_root + app + stage
    end

  end

end