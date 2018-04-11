module Fauxpaas
  class Invoker

    # TODO: test this
    def add_command(command)
      run(command)
    end

    private

    def validate!(command)
      unless command.valid?
        raise KeyError, "Missing keys: #{command.missing.join(", ")}"
      end
    end

    # TODO: test this
    def run(command)
      validate!(command)
      command.execute
    end

  end
end

