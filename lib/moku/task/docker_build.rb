# frozen_string_literal: true

require "moku/task/task"

module Moku
  module Task

    # TBA
    class DockerBuild < Task

      # @param artifact [Artifact]
      # @return [Status]
      def call(artifact)
        artifact.with_env do
          release_id = artifact.path.basename
          dockerlog = `docker build -t mokuapp:#{release_id} -f Dockerfile.prod . | tee /tmp/dockerdebug.txt | tail -10`
          status = $?
          if status == 0
            Status.success
          else
            Status.failure(dockerlog)
          end
        end
      end

    end

  end
end
