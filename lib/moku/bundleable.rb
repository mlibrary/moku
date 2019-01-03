# frozen_string_literal: true

module Moku

  # A module that can be included in objects that have a bundler context.
  module Bundleable

    # Evaluate some block in the context of this object's path, shedding
    # our own bundler context.
    def with_env
      Bundler.with_clean_env do
        Dir.chdir(path) do
          yield
        end
      end
    end
  end

end
