# frozen_string_literal: true

module Moku

  # Indicates that an instance was already in use by another process.
  class InstanceBusyError < RuntimeError
    def message
      "The specified instance was already checked out by another process."
    end
  end
end
