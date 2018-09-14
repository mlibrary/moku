# frozen_string_literal: true

require "ostruct"

module Fauxpaas

  # A list of commands in a set order, typically user-provided.
  class StepList

    def initialize(content)
      @content = content
    end

    def steps
      content.map do |raw_step|
        OpenStruct.new(cmd: raw_step["cmd"])
      end
    end

    private

    attr_reader :content
  end
end
