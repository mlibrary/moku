# frozen_string_literal: true

require "moku/sites/scope"
require "yaml"

module Moku

  # A list of tasks encoded in a file.
  class TaskFile
    include Enumerable

    def initialize(path)
      @path = path
    end

    def each
      tasks.each {|task| yield(task) }
    end

    private

    attr_reader :path

    def tasks
      @tasks ||= raw_tasks.map do |raw_task|
        { cmd: raw_task["cmd"], scope: scope(raw_task["per"]) }
      end
    end

    # The tasks encoded in the file
    # @return [Array<Hash>]
    def raw_tasks
      @raw_tasks ||= if path.exist?
        YAML.safe_load(File.read(path)) || []
      else
        []
      end
    end

    def scope(per)
      case per
      when "host", nil
        Sites::Scope.all
      when "site"
        Sites::Scope.each_site
      when "deploy"
        Sites::Scope.once
      else
        raise ArgumentError, "Unknown scope or value for 'per'"
      end
    end

  end
end
