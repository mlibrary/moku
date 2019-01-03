# frozen_string_literal: true

module Moku
  module WithContext
    def within(path)
      Bundler.with_clean_env do
        Dir.chdir(path) do
          yield "PATH=$RBENV_ROOT/versions/$(rbenv local)/bin:$PATH"
        end
      end
    end
  end
end

RSpec.configure do |c|
  c.extend Moku::WithContext
end
