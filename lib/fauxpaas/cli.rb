# frozen_string_literal: true

require "fauxpaas/cli/main"

module Fauxpaas
  # Command-Line Interface
  module CLI
    def self.start(argv)
      Main.start(argv)
    end
  end
end
