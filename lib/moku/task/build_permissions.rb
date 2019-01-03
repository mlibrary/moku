# frozen_string_literal: true

require "moku/task/task"
require "fileutils"
require "find"
require "pathname"

module Moku
  module Task

    # Sets permissions on the files and directories of the artifact.
    class BuildPermissions < Task

      # A set of permissions that can be applied to a directory and its descendants.
      #
      # We assume that you # will want to allow other users to read and write to the
      # files after the fact. This  is enabled via enabling group read/write/execute;
      # system administrators then need only to add the real user to the application
      # user's group. Finally, we set both the setuid and setgid bits to ensure that
      # users' actions never result in files that fall outside of this paradigm.
      class Permissions
        def initialize(bin:, dir:, file:)
          @bin = bin
          @dir = dir
          @file = file
        end

        # @param base_dir [Pathname]
        def apply(base_dir)
          FileUtils.mkdir_p base_dir
          Find.find(base_dir).map {|f| Pathname.new(f) }.each do |path|
            FileUtils.chmod(mode(path), path)
          end
        end

        private

        attr_reader :bin, :dir, :file

        # @param path [Pathname]
        # @return [Numeric] The mode, as given by the constructor.
        def mode(path)
          if path.directory?
            dir
          elsif path.executable?
            bin
          else
            file
          end
        end

      end

      # @param artifact [Artifact]
      # @return [Status]
      def call(artifact) # rubocop:disable Metrics/AbcSize
        artifact.with_env do
          private_permissions.apply(artifact.path)
          sensitive_permissions.apply(artifact.path/"log")
          public_permissions.apply(artifact.path/"public")
          public_permissions.apply(artifact.path/"public"/"assets")
        end
      end

      private

      def private_permissions
        @private_permissions ||= Permissions.new(bin: 0o6770, dir: 0o2775, file: 0o660)
      end

      def public_permissions
        @public_permissions ||= Permissions.new(bin: 0o6775, dir: 0o2775, file: 0o664)
      end

      def sensitive_permissions
        @sensitive_permissions ||= Permissions.new(bin: 0o6770, dir: 0o2770, file: 0o660)
      end

    end

  end
end
