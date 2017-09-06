require "thor"
require "fauxpaas/cli/file"
require "fauxpaas/cli/log"
require "fauxpaas/cli/var"

module Fauxpaas
  module CLI

    class Main < Thor
      desc "deploy <named_instance> <branch or sha>", "Deploy!"
      def deploy(named_instance, target); end

      desc "caches <named_instance>", "List cached deployments"
      def caches(named_instance); end

      desc "rollback <named_instance> <cache>", "Rollback to a cached deployment"
      def rollback(named_instance, cache); end

      desc "var SUBCOMMAND", "View and manage configuration variables"
      subcommand "var", Var

      desc "file SUBCOMMAND", "View and manage configuration files"
      subcommand "file", File

      desc "log SUBCOMMAND", "View and manage logs"
      subcommand "log", Log
    end

  end
end
