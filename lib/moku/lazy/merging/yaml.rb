# frozen_string_literal: true

require "moku/lazy/origin"
require "yaml"
require "ettin"

module Moku
  module Lazy
    module Merging

      # A strategy for merging two yaml files.
      class Yaml < Origin
        register(self)

        EXTENSIONS = [".yml", ".yaml"].freeze

        def self.handles?(*sources)
          sources.size == 2 &&
            EXTENSIONS.include?(sources.first.extname) &&
            EXTENSIONS.include?(sources.last.extname)
        end

        def extname
          ".yml"
        end

        def read
          YAML.dump(Ettin.for(sources.map(&:read)).to_h)
        end
      end

    end
  end
end
