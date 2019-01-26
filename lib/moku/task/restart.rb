# frozen_string_literal: true

require "moku/task/task"
require "moku/sequence"
require "moku/sites/scope"

module Moku
  module Task

    # Restart the release's systemd services on the target hosts.
    class Restart < Task
      def call(release)
        Sequence.for(release.systemd_services) do |service|
          release.run(Sites::Scope.all, "sudo systemctl restart #{service}")
        end
      end
    end

  end
end
