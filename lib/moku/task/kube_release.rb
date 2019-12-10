# frozen_string_literal: true

require "moku/task/task"

module Moku
  module Task

    class KubeRelease < Task

      # @param release [Release]
      # @return [Status]
      def call(release)
        release.artifact.with_env do
          release_id = release.artifact.path.basename
          kubelog = `IMAGE_TAG=#{release_id} ./deployment.yaml.sh | kubectl apply -f -`

          status = $?
          if status == 0
            Status.success
          else
            Status.failure(kubelog)
          end
        end
      end

    end

  end
end
