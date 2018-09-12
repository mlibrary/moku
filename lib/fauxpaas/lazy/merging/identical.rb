# frozen_string_literal: true

require "fauxpaas/lazy/origin"

module Fauxpaas
  module Lazy
    module Merging

      # Controls the identify property for merging origins. I.e. two
      # origins with the same location are identical, and a single
      # origin is identical to itself.
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

        def merge?
          false
        end
      end

    end
  end
end
