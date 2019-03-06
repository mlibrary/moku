# frozen_string_literal: true

require "moku/task/task"
require "moku/sequence"
require "moku/sites/scope"

module Moku
  module Task

    # Enable the release's systemd services on the target hosts.
    class Enable < Task
      def call(release)
        Sequence.for(release.systemd_services) do |service|
          release.run(Sites::Scope.all, "sudo systemctl enable #{service}")
        end
      end
    end

  end
end
