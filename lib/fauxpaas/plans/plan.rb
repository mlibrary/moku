# frozen_string_literal: true

require "fauxpaas/status"

module Fauxpaas
  module Plans

    # A plan is a series of tasks assembled to achieve a particular purpose. When
    # a plan is executed, it procedes through the tasks sequentially until either
    # the series if finished, or a failure is encountered.
    #
    # Plans are divided into three phases: prepare, main, and finish, in that order.
    # These phases are evaluated separately. {#prepare} is called first, and {#main} is
    # not called until the tasks it defines have each executed successfully. The same
    # relationship exists between {#main} and {#finish}. This allows for the latter
    # two phases to determine their tasks at runtime based on changes made by the
    # previous phases.
    #
    # @abstract Plans should be subclasses that override one or more of {#prepare},
    #   {#main}, and/or {#finish}.
    class Plan

      # @param target [Artifact,Release] This could be an artifact or a release
      def initialize(target)
        @target = target
      end

      # Execute the tasks of the plan. If a task fails, halt this process. This
      # method returns the status of the last task.
      # @return [Status]
      def call
        status = run(prepare)
        if status.success?
          status = run(main)
          if status.success?
            status = run(finish)
          end
        end
        status
      end

      # @return [Artifact,Release]
      attr_reader :target

      protected

      # @return [Array<Task>]
      def prepare
        []
      end

      # @return [Array<Task>]
      def main
        []
      end

      # @return [Array<Task>]
      def finish
        []
      end

      private

      # Run a list of tasks, stopping if any failure to return a successful
      # status object.
      # @return [Status] The result of the last task. If no tasks were given,
      #   then this will be a successful Status.
      def run(tasks)
        tasks.reduce(Status.success) do |last_result, task|
          break(last_result) unless last_result.success?

          task.call(target)
        end
      end

    end

  end
end
