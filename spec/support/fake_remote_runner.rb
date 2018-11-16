# frozen_string_literal: true

module Moku
  class FakeRemoteRunner
    def initialize(system_runner)
      @system_runner = system_runner
    end

    def run(host:, command:, user: Moku.user) # rubocop:disable Lint/UnusedMethodArgument
      system_runner.run(command)
    end

    private

    attr_reader :system_runner
  end
end
