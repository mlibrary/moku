# frozen_string_literal: true

require "moku/sequence"

module Moku
  module Plan

    # A plan is a series of tasks assembled to achieve a particular purpose. When
    # a plan is executed, it procedes through the tasks sequentially until either
    # the series is finished, or a failure is encountered.
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

      # @param target [Object] The object upon which the plan operates.
      def initialize(target, logger: Moku.logger)
        @target = target
        @logger = logger
      end

      # Execute the tasks of the plan. If a task fails, halt this process. This
      # method returns the status of the last task to run.
      # @return [Status]
      def call
        Sequence.do([
          proc { run(prepare) },
          proc { run(main) },
          proc { run(finish) }
        ])
      end

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

      attr_reader :target, :logger

      private

      # Run a list of tasks, stopping if any fail to return a successful
      # status object. This plan's target will be passed to each task's #call
      # method.
      # @param tasks [Array<Task>]
      # @return [Status] The result of the last task. If no tasks were given,
      #   then this will be a successful Status.
      def run(tasks)
        Sequence.for(tasks) do |task|
          logger.info "Starting: #{task}"
          task.call(target)
        end
      end

    end

  end
end
