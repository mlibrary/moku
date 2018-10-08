# frozen_string_literal: true

require "fauxpaas/task/task"
require "fauxpaas/sequence"

module Fauxpaas
  module Task

    # Restart the release's systemd services on the target hosts.
    class Restart < Task
      def call(release)
        Sequence.for(release.systemd_services) do |service|
          release.run_per_host("sudo systemctl restart #{service}")
        end
      end
    end

  end
end
