# frozen_string_literal: true

module Moku

  # Responsible for when and where commands are executed
  class Invoker

    def initialize(authority:, pipeline_factory:)
      @authority = authority
      @pipeline_factory = pipeline_factory
    end

    def add_command(command)
      run(command)
    end

    private

    attr_reader :authority, :pipeline_factory

    def run(command)
      authorize!(command)
      pipeline_factory.for(command).call
    rescue StandardError => e
      Moku.logger.fatal "#{e.message}\n\t#{e.backtrace.join("\n\t")}"
    end

    def authorize!(command)
      unless command.authorized?
        raise "User is not authorized to peform this command"
      end
    end

  end
end
