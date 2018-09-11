require "fauxpaas/lazy/origin"
require "yaml"
require "ettin"

module Fauxpaas
  module Lazy
    module Merging

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
