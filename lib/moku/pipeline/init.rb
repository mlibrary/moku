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
      register(self)

      def self.handles?(command)
        command.action == :init
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

      attr_reader :dir

      def create_tmpdir
        FileUtils.mkdir_p Moku.tmp_root
        @dir = Pathname.new(Dir.mktmpdir(nil, Moku.tmp_root))
      end

      def precheck
        if command.first_run?
          Status.success
        else
          Status.failure("Instance #{command.instance_name} already initialized")
        end
      end

      def write_deploy
        sites = Hash.new {|h, k| h[k] = [] }
        command.content["deploy"]["sites"]["nodes"]
          .map(&:to_a)
          .flatten(1)
          .each {|host, site| sites[site] << host }
        sites["user"] = command.content["deploy"]["sites"]["user"]

        deploy_content = command.content["deploy"]
          .merge("sites" => sites)

        path = dir/Moku.deploy_repo_name/"deploy.yml"
        FileUtils.mkdir_p path.dirname
        File.write(path, YAML.dump(deploy_content))
      end

      def write_infrastructure
        path = dir/Moku.infra_repo_name/"infrastructure.yml"
        FileUtils.mkdir_p path.dirname
        File.write(path, YAML.dump(command.content["infrastructure"]))
      end

      def write_dev
        FileUtils.mkdir_p dir/Moku.dev_repo_name
        (command.rails? ? "rails" : "default").tap do |rails_or_nah|
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

      def push
        Sequence.do([
          Push.new(
            dir: dir/Moku.deploy_repo_name,
            repo: Moku.deploy_repo,
            branch: command.instance_name
          ),
          Push.new(
            dir: dir/Moku.dev_repo_name,
            repo: Moku.dev_repo,
            branch: command.instance_name
          ),
          Push.new(
            dir: dir/Moku.infra_repo_name,
            repo: Moku.infra_repo,
            branch: command.instance_name
          )
        ])
      end

      def install_instance
        path = Moku.instance_root/command.instance_name/"instance.yml"
        FileUtils.mkdir_p path.dirname
        File.write(path, YAML.dump(command.content["instance"]))
      end

      def install_permissions
        path = Moku.instance_root/command.instance_name/"permissions.yml"
        FileUtils.mkdir_p path.dirname
        File.write(path, YAML.dump(command.content["permissions"]))
      end

      def cleanup
        FileUtils.remove_entry_secure dir if dir
      end

    end

  end
end
