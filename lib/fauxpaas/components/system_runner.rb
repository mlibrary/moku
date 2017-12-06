require "fauxpaas/open3_capture"

module Fauxpaas
  class << self
    def system_runner
      @system_runner ||= Open3Capture.new
    end

    attr_writer :system_runner
  end
end
