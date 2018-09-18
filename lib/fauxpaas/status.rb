# frozen_string_literal: true

module Fauxpaas

  # A generic wrapper over the result of some operation.
  class Status

    def self.success
      new(true)
    end

    def self.failure(error)
      new(false, error)
    end

    # @param status [Boolean]
    # @param errors [Array]
    def initialize(status, error = "")
      @status = status
      @error = error
    end

    # Any error reported
    # @return [String]
    attr_reader :error

    # @return [Boolean]
    def success?
      @status
    end

    def eql?(other)
      if success?
        success? == other.success?
      else
        success? == other.success? &&
          error == other.error
      end
    end
    alias_method :==, :eql?
  end

end
