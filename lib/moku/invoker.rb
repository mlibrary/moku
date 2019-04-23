# frozen_string_literal: true

module Moku

  # Responsible for when and where commands are executed
  class Invoker

    def initialize(authority:, logger:)
      @authority = authority
      @logger = logger
    end

    def add_command(command)
      run(command)
    end

    private

    attr_reader :authority, :logger

    def run(command)
      authorize!(command)
      command.call
    rescue StandardError => e
      logger.fatal "#{e.message}\n\t#{e.backtrace.join("\n\t")}"
    end

    def authorize!(command)
      unless authorized?(command)
        raise "User is not authorized to peform this command"
      end
    end

    def authorized?(command)
      authority.authorized?(
        user: command.user,
        entity: command.instance,
        action: command.action
      )
    end

  end
end
