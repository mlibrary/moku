# frozen_string_literal: true

require "moku/task/task"
require "moku/sites/scope"
require "moku/status"

module Moku
  module Task

    # Install site-specific files into the common files via symlink
    class OverlaySites < Task

      def call(release)
        Sequence.for(
          release.sites.site_names.flat_map do |site_name|
            [
              [Sites::Scope.site(site_name), mkdir_command(site_name)],
              [Sites::Scope.site(site_name), link_command(site_name)]
            ]
          end
        ) {|scope, cmd| release.run(scope, cmd) }
      end

      private

      def mkdir_command(site_name)
        "test ! -d sites/#{site_name} || " \
          "find sites/#{site_name} -type d " \
          "| sed -e 's/^sites\\/#{site_name}/./' " \
          "| while read i; do mkdir -p \"$i\"; done"
      end

      def link_command(site_name)
        site_path = "$PWD/sites/#{site_name}"
        "test ! -d #{site_path} || " \
          "find #{site_path} -type f " \
          "| sed -e \"s,^#{site_path}/,,\" " \
          "| while read i; do ln -s \"#{site_path}/$i\" \"./$i\"; done"
      end
    end

  end
end
