module Fauxpaas
  class FakeRemoteRunner
    def initialize(system_runner)
      @system_runner = system_runner
    end

    def run(host:, command:, user: Fauxpaas.user)
      system_runner.run(command)
    end

    private

    attr_reader :system_runner
  end
end
