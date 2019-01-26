# frozen_string_literal: true

require "moku/task/task"

module Moku
  module Task

    # Upload the artifact
    class Upload < Task

      def initialize(runner: Moku.system_runner, upload_factory: Moku.upload_factory)
        @runner = runner
        @upload_factory = upload_factory
      end

      def call(release)
        Sequence.for(release.sites.hosts) do |host|
          upload_factory.new(release.path, host, release.deploy_path)
            .with(runner)
        end
      end

      private

      attr_reader :runner, :upload_factory

    end

  end
end
