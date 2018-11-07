# frozen_string_literal: true

require "moku/lazy/origin"

module Moku
  module Lazy
    module Merging

      # The overwrite strategy; the lhs origin is preferred
      # over the rhs. This is a default strategy.
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
