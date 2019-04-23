# frozen_string_literal: true

require "moku"
require "moku/command/command"
require "moku/pipeline/read_default_branch"

module Moku
  module Command

    # Show the instance's default source branch
    class ReadDefaultBranch < Command
      def action
        :read_default_branch
      end

      def call
        Pipeline::ReadDefaultBranch.new(instance: instance).call
      end

    end

  end
end
