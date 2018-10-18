# frozen_string_literal: true

require "fauxpaas/task/task"

module Fauxpaas
  module Task

    # Upload the artifact
    class Upload < Task

      def initialize(runner: Fauxpaas.system_runner)
        @runner = runner
      end

      def call(release)
        runner.run(command(release.path, release.deploy_path))
      end

      private

      attr_reader :runner

      def command(source, dest)
        "rsync -vrlpz #{source}/. #{dest}/"
      end
    end

  end
end