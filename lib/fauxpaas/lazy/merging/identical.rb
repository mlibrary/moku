require "fauxpaas/lazy/origin"

module Fauxpaas
  module Lazy
    module Merging

      class Identical < Origin
        register(self)

        def self.handles?(*sources)
          sources.uniq.size == 1
        end

        def extname
          sources.last.extname
        end

        def read
          sources.first.read
        end

        def is_merge?
          false
        end
      end

    end
  end
end
