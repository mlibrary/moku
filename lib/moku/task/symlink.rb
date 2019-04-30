# frozen_string_literal: true

require "moku/task/task"
require "moku/sites/scope"

module Moku
  module Task

    # Create a symlink for eac path pair defined in infrastructure.yml
    class Symlink < Task

      def call(release)
        release.run(Sites::Scope.all, command.strip)
      end

      private

      def command
        <<~'CMD'
          ruby \
          -e 'require "yaml"' \
          -e 'require "pathname"' \
          -e 'if File.exist?("infrastructure.yml")' \
          -e 'YAML.load_file("infrastructure.yml")["path"].each do |link,target|' \
          -e '`rm -rf #{Pathname.new(link).cleanpath} && ln -s #{target} #{link}`' \
          -e 'end' \
          -e 'end'
        CMD
      end

    end

  end
end
