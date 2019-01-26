# frozen_string_literal: true

module Moku

  # A generic wrapper over the result of some operation.
  class Status

    def self.success(output = "")
      new(true, output, "")
    end

    def self.failure(error = "")
      new(false, "", error)
    end

    # @param success [Boolean]
    # @param output [String]
    # @param error [String]
    def initialize(success, output = "", error = "")
      @success = success
      @output = output
      @error = error
    end

    # Any error reported
    # @return [String]
    attr_reader :output, :error

    # @return [Boolean]
    def success?
      @success
    end

    def eql?(other)
      success? == other.success? &&
        output == other.output &&
        error == other.error
    end
    alias_method :==, :eql?
  end

end
