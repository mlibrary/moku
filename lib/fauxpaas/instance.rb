require "pathname"

module Fauxpaas

  # Represents a named instance within fauxpaas, as opposed
  # to installed on destination servers.
  class Instance
    def initialize(name:, source:, release_root:, deploy_user:)
      @app, @stage = name.split("-")
      @source = source
      @release_root = Pathname.new(release_root)
      @deploy_user = deploy_user
    end

    # Source reference
    # @return [Source]
    attr_reader :source

    # Root directory where releases are deployed
    # I.e. the current release will be release_root/current
    # @return [Pathname]
    attr_reader :release_root

    # The user that will be used to run commands on the
    # remote machines.
    # @return [String]
    attr_reader :deploy_user

    def name
      "#{app}-#{stage}"
    end

    attr_reader :app, :stage

  end

end
