# frozen_string_literal: true

require "moku/task/task"
require "moku/sites/scope"

module Moku
  module Task

    # Create a symlink for eac path pair defined in infrastructure.yml
    class Symlink < Task

      def call(release)
        release.run(Sites::Scope.all, command)
      end

      private

      def command
        <<~'CMD'
          ruby -e 'require "yaml"; YAML.load_file("infrastructure.yml")["path"].each{|k,v| `ln -s #{v} #{k}`} if File.exist?("infrastructure.yml")'
        CMD
      end

    end

  end
end
