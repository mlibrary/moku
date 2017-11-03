require "open3"

module Fauxpaas
  class Open3Capture
    def run(string)
      Open3.capture3(string)
    end
  end
end
