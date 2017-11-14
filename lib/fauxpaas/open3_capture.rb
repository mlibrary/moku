# frozen_string_literal: true

require "open3"

module Fauxpaas

  # Runner that uses Open3.capture3
  class Open3Capture
    def run(string)
      Open3.capture3(string)
    end
  end
end
