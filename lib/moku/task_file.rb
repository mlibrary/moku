# frozen_string_literal: true

require "moku/sites/scope"
require "yaml"

module Moku

  # A list of tasks encoded in a file. Typically, this is used to allow
  # users to extend builds or deploys with their own list of tasks in a yaml
  # file.
  class TaskFile
    include Enumerable

    TaskSpec = Struct.new(:command, :scope)

    def self.from_path(path)
      raw_tasks = if path.exist?
        YAML.safe_load(File.read(path)) || []
      else
        []
      end
      new(raw_tasks)
    end

    def initialize(raw_tasks)
      @raw_tasks = [raw_tasks].flatten.compact
    end

    def each
      tasks.each {|task| yield(task) }
    end

    private

    attr_reader :raw_tasks

    def tasks
      @tasks ||= raw_tasks.map do |raw_task|
        if raw_task.is_a? Hash
          TaskSpec.new(raw_task["cmd"], scope(raw_task["scope"]))
        else
          TaskSpec.new(raw_task, scope(nil))
        end
      end
    end

    # Retrieve a scope object from the user's string specification of a scope.
    def scope(user_scope)
      case user_scope
      when "all"
        Sites::Scope.all
      when "site", "each_site"
        Sites::Scope.each_site
      when "deploy", "once", nil
        Sites::Scope.once
      else
        raise ArgumentError, "Unknown scope or value '#{user_scope}'"
      end
    end

  end
end
