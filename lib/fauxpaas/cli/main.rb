require "thor"
require "fauxpaas"
require "fauxpaas/cli/log"

module Fauxpaas
  module CLI

    class Main < Thor
      desc "create <named_instance>", "Create a new named instance skeleton"
      def create(named_instance); end

      desc "caches <named_instance>", "List cached deployments"
      def caches(named_instance); end

      desc "deploy <named_instance> <branch or sha>", "Deploy!"
      def deploy(named_instance, target); end

      desc "rollback <named_instance> <cache>", "Rollback to a cached deployment"
      def rollback(named_instance, cache); end

      desc "history <named_instance>", "Show deploy history"
      def history(named_instance)
        #TODO: Authz
        History.new(Instance.new(named_instance)).list
      end

      desc "log SUBCOMMAND", "View and manage logs"
      subcommand "log", Log
    end

  end
end
