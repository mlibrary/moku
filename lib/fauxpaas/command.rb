module Fauxpaas

  # Encapsulates a custom command
  class Command
    attr_reader :role, :bin, :options
    def initialize(role, command)
      @role = role.to_sym
      @bin, @options = command.split(" ", 2)
      @bin = @bin.to_sym
    end
  end

end
