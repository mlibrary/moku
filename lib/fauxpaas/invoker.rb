# frozen_string_literal: true

require "fauxpaas/pipeline"

module Fauxpaas

  # Responsible for when and where commands are executed
  class Invoker

    # TODO: test this
    def add_command(command)
      run(command)
    end

    private

    def run(command)
      authorize!(command)
      Pipeline.for(command).call
      nil
    rescue StandardError => e
      Fauxpaas.logger.fatal e.message
      raise # TODO swallow this exception
    end

    def authorize!(command)
      unless command.authorized?
        raise "User is not authorized to peform this command"
      end
    end

  end
end
