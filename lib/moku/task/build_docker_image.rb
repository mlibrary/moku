# frozen_string_literal: true

require "moku/task/task"

require "tempfile"
require "open3"

module Moku
  module Task

    # Build an application image with Docker.
    #
    # This task only builds the image with a local tag; it does not push.
    class BuildDockerImage < Task

      attr_reader :instance

      def initialize(instance)
        @instance = instance
      end

      def app_name
        instance.name
      end

      def uid
        instance.deploy_config.uid
      end

      def gid
        instance.deploy_config.gid
      end

      def url_root
        instance.deploy_config.url_root || '/'
      end

      # @param artifact [Artifact]
      # @return [Status]
      def call(artifact)
        artifact.with_env do
          release_id = artifact.path.basename
          cmd = <<~CMD
            docker build \
              --build-arg UID=#{uid} \
              --build-arg GID=#{gid} \
              --build-arg URL_ROOT=#{url_root} \
              -t #{app_name}:#{release_id} \
              -f Dockerfile.prod .
          CMD
          output, status = Open3.capture2e(cmd)

          if status.success?
            Status.success(output.lines.last(2).join)
          else
            Tempfile.open("docker-build") do |file|
              file.write(output)
              msg = <<~MSG
                Running `docker build` failed... examine #{file.path} for details.
                Last five lines of output:
                #{output.lines.last(5).map {|line| "\t#{line}" }.join}
              MSG
              Status.failure(msg)
            end
          end
        end
      end

    end

  end
end
