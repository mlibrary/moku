# frozen_string_literal: true

require "moku/task/task"

module Moku
  module Task

    class DockerPush < Task

      # @param release [Release]
      # @return [Status]
      def call(release)
        release.artifact.with_env do
          release_id = release.artifact.path.basename
          appname    = "mokuapp"
          localtag   = "#{appname}:#{release_id}"
          repotag    = "docker-registry.umdl.umich.edu:80/deepbluedata-testing:#{release_id}"

          dockerlog = `docker tag #{localtag} #{repotag} && docker push #{repotag}`
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
