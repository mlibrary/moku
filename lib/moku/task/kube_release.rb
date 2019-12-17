# frozen_string_literal: true

require "moku/task/task"

module Moku
  module Task

    # Release an application to a Kubernetes cluster.
    #
    # This amounts to creating or updating a Deployment, which will pull the
    # newly pushed image and restart containers accordingly.
    class KubeRelease < Task
      attr_reader :instance

      def initialize(instance)
        @instance = instance
      end

      def image_name
        instance.name
      end

      # @param release [Release]
      # @return [Status]
      def call(release)
        release.artifact.with_env do
          release_id = release.artifact.path.basename
          kubelog = `IMAGE_NAME=#{image_name} IMAGE_TAG=#{release_id} ./deployment.yaml.sh | kubectl apply -f -`

          if $?.success?
            Status.success
          else
            Status.failure(kubelog)
          end
        end
      end

    end

  end
end
