require "fauxpaas/lazy/origin"

module Fauxpaas
  module Lazy
    module Merging

      class Overwrite < Origin
        register_default(self)

        def self.handles?(_sources)
          true
        end

        def extname
          sources.last.extname
        end

        def read
          sources.last.read
        end
      end

    end
  end
end
