module Fauxpaas

  # Encapsulates a custom command
  class Command
    attr_reader :role, :bin, :options
    def initialize(role, bin, options)
      @role = role.to_sym
      @bin = bin.to_sym
      @options = options
    end
  end

end
