require "fauxpaas/cli/file"
require "fauxpaas/cli/log"
require "fauxpaas/cli/main"
require "fauxpaas/cli/var"

module Fauxpaas
  module CLI
    def self.start(argv)
      Main.start(argv)
    end
  end
end
