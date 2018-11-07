# frozen_string_literal: true

require "yaml"

module Moku

  # A list of tasks encoded in a file.
  class TaskFile
    include Enumerable

    def initialize(path)
      @path = path
    end

    def each
      raw_tasks.each {|task| yield(task) }
    end

    private

    attr_reader :path

    # The tasks encoded in the file
    # @return [Array<Hash>]
    def raw_tasks
      @raw_tasks ||= if path.exist?
        YAML.safe_load(File.read(path)) || []
      else
        []
      end
    end

  end
end
