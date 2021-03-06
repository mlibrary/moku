# frozen_string_literal: true

module Moku

  # Spoof a runner to remote hosts by relying on the system runner
  # and local file paths.
  class FakeRemoteRunner
    def initialize(system_runner)
      @system_runner = system_runner
    end

    def run(host:, command:, user: Moku.user) # rubocop:disable Lint/UnusedMethodArgument
      (Moku.deploy_root/host).mkpath
      Dir.chdir(Moku.deploy_root/host) do |dir|
        # Treat the dir as if it were a remote host
        system_runner.run(command.gsub(/ \//, " #{dir}/"))
      end
    end

    private

    attr_reader :system_runner
  end
end
