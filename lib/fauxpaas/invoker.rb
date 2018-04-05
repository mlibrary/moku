module Fauxpaas
  class Invoker

    # TODO: test this
    def add_command(command)
      run(command)
    end

    private

    # TODO: test this
    def run(command)
      begin
        validate!(command)
        authorize!(command)
        command.execute
      rescue StandardError => e
        Fauxpaas.logger.fatal e.message
        raise #TODO swallow this exception
      end
    end

    def authorize!(command)
      unless command.authorized?
        raise RuntimeError, "User is not authorized to peform this command"
      end
    end

    def validate!(command)
      unless command.valid?
        raise KeyError, "Missing keys:\n\t#{command.missing.join(" ,")}"
      end
    end

  end
end

