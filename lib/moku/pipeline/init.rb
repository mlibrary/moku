# frozen_string_literal: true

require "moku/pipeline/pipeline"
require "moku/push"
require "moku/status"
require "fileutils"
require "pathname"
require "tmpdir"

module Moku
  module Pipeline

    # Execute an arbitrary command
    class Init < Pipeline

      def initialize(instance:, first_run:, content:, rails:)
        @instance = instance
        @first_run = first_run
        @content = content
        @rails = rails
      end

      def call
        step :create_tmpdir
        step :precheck
        step :write_deploy
        step :write_dev
        step :write_infrastructure
        step :push
        step :install_permissions
        step :install_instance
      ensure
        step :cleanup
      end

      private

      def first_run?
        @first_run
      end

      def rails?
        @rails
      end

      attr_reader :instance, :content
      attr_reader :dir

      def create_tmpdir
        FileUtils.mkdir_p Moku.tmp_root
        @dir = Pathname.new(Dir.mktmpdir(nil, Moku.tmp_root))
      end

      def precheck
        if first_run?
          Status.success
        else
          Status.failure("Instance #{instance.name} already initialized")
        end
      end

      def write_deploy # rubocop:disable Metrics/AbcSize
        sites = Sites.for(content["deploy"]["sites"])

        deploy_content = content["deploy"]
          .merge("sites" => sites.to_h)

        path = dir/Moku.deploy_repo_name/"deploy.yml"
        FileUtils.mkdir_p path.dirname
        File.write(path, YAML.dump(deploy_content))
      end

      def write_infrastructure
        path = dir/Moku.infra_repo_name/"infrastructure.yml"
        FileUtils.mkdir_p path.dirname
        File.write(path, YAML.dump(content["infrastructure"]))
      end

      def write_dev # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        FileUtils.mkdir_p dir/Moku.dev_repo_name
        (rails? ? "rails" : "default").tap do |rails_or_nah|
          FileUtils.cp(
            Moku.default_root/rails_or_nah/Moku.finish_build_filename,
            dir/Moku.dev_repo_name/Moku.finish_build_filename
          )
          FileUtils.cp(
            Moku.default_root/rails_or_nah/Moku.finish_deploy_filename,
            dir/Moku.dev_repo_name/Moku.finish_deploy_filename
          )
        end
      end

      def push # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        Sequence.do([
          Push.new(
            dir: dir/Moku.deploy_repo_name,
            repo: Moku.deploy_repo,
            branch: instance.name
          ),
          Push.new(
            dir: dir/Moku.dev_repo_name,
            repo: Moku.dev_repo,
            branch: instance.name
          ),
          Push.new(
            dir: dir/Moku.infra_repo_name,
            repo: Moku.infra_repo,
            branch: instance.name
          )
        ])
      end

      def install_instance
        path = Moku.instance_root/instance.name/"instance.yml"
        FileUtils.mkdir_p path.dirname
        File.write(path, YAML.dump(content["instance"]))
      end

      def install_permissions
        path = Moku.instance_root/instance.name/"permissions.yml"
        FileUtils.mkdir_p path.dirname
        File.write(path, YAML.dump(content["permissions"]))
      end

      def cleanup
        FileUtils.remove_entry_secure dir if dir
      end

    end

  end
end
