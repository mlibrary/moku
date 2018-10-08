# frozen_string_literal: true

require "fauxpaas/plan/plan"
require "fauxpaas/task/restart"

module Fauxpaas
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
