# frozen_string_literal: true

require "moku/plan/plan"
require "moku/task/restart"

module Moku
  module Plan

    # Restart the service running on remote hosts
    class Restart < Plan
      def main
        [
          Task::Restart.new
        ]
      end
    end
  end
end
