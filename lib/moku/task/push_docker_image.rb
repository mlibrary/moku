# frozen_string_literal: true

require "moku/task/task"

require "tempfile"
require "open3"

module Moku
  module Task

    # Push a prebuilt application image to a Docker registry
    class PushDockerImage < Task
      attr_reader :instance

      def initialize(instance)
        @instance = instance
      end

      def app_name
        instance.name
      end

      # @param release [Release]
      # @return [Status]
      def call(release)
        release.artifact.with_env do
          release_id = release.artifact.path.basename
          localtag   = "#{app_name}:#{release_id}"
          repotag    = "docker-registry.umdl.umich.edu:80/#{localtag}"

          cmd = "docker tag #{localtag} #{repotag} && docker push #{repotag}"

          output, status = Open3.capture2e(cmd)

          if status.success?
            Status.success(output.lines.last(2).join)
          else
            Tempfile.open("docker-push") do |file|
              file.write(output)
              msg = <<~MSG
                Running `docker push` failed... examine #{file.path} for details.
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
