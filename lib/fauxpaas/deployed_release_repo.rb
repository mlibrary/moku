# frozen_string_literal: true

module Fauxpaas

  # Creates and persists deployed releases
  class DeployedReleaseRepo

    def create(name:, deploy_user:, release_root:, source:); end

    private

    def path
      Fauxpaas.instance_root + app + stage
    end

  end

end
