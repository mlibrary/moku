# frozen_string_literal: true

require "fauxpaas/tasks/shell"
require "yaml"

module Fauxpaas

  # A list of tasks encoded in a file. This is typically used to
  # translate e.g. finish_build.yml into a list of tasks.
  class TaskFile

    # @param path [Pathname] The pat to the file
    def initialize(path, task_type: Tasks::Shell)
      @content = YAML.safe_load(File.read(path))
      @task_type = task_type
    end

    # The tasks encoded in the file
    # @return [Array<Task::Shell>]
    def tasks
      content.map do |raw_step|
        task_type.new(raw_step["cmd"])
      end
    end

    private

    attr_reader :content, :task_type
  end
end
