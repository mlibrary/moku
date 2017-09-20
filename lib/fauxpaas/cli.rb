require "fauxpaas/cli/main"

module Fauxpaas
  module CLI
    def self.start(argv)
      Main.start(argv)
    end
  end
end
