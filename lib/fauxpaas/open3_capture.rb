# frozen_string_literal: true

require "open3"

module Fauxpaas

  # Runner that uses Open3.capture3
  class Open3Capture
    def run(string, clean_env: true)
      if clean_env
        Bundler.with_clean_env do
          Open3.capture3(string)
        end
      else
        Open3.capture3(string)
      end
    end
  end
end
