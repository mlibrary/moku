require "fauxpaas/cap_runner"
require "fauxpaas/components/system_runner"

module Fauxpaas
  class << self
    def backend_runner
      @backend_runner ||= CapRunner.new(system_runner)
    end
  end
end
