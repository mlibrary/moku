# frozen_string_literal: true

module Fauxpaas
  class FakeRemoteRunner
    def initialize(system_runner)
      @system_runner = system_runner
    end

    def run(host:, command:, user: Fauxpaas.user) # rubocop:disable Lint/UnusedMethodArgument
      system_runner.run(command)
    end

    private

    attr_reader :system_runner
  end
end
