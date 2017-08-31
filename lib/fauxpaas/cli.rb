require "thor"

module Fauxpaas
  module CLI

    class Config < Thor
      desc "list <named_instance>", "List out the config"
      def list(named_instance); end

      desc "set <named_instance> <key> <value>", "Set the key to value on subsequent deploys"
      def set(named_instance, key, value); end

      desc "unset <named_instance> <key>", "Unset the key to value on subsequent deploys"
      def unset(named_instance, key); end

      desc "upload <named_instance> <app_path> <local_path>",
        "Add a file to be installed to <app_path> on subsequent deploys"
      def upload(named_instance, destpath, file); end

      desc "remove <named_instance> <app_path>",
        "Cease installing the file to <app_path> on subsequent deploys"
      def remove(named_instance, destpath); end
    end

    class Log < Thor
      desc "list <named_instance>", "List the known log files"
      def list(named_instance); end

      desc "grep <named_instance> <pattern> <log>", "Grep a log file for the given regex"
      def grep(named_instance, pattern, log); end

      desc "tail <named_instance> <log>", "Tail a log file"
      def tail(named_instance, log); end

      desc "cat <named_instance> <log>", "Display a log file"
      option aliases: [:display, :show]
      def cat(named_instance, log); end

      desc "add <named_instance> <path>", "Add the path to the list of known log files"
      def add(named_instance, path); end

      desc "remove <named_instance> <path>", "Remove the path to the list of known log files"
      def remove(named_instance, path); end
    end

    class Main < Thor
      desc "deploy <named_instance> <branch or sha>", "Deploy!"
      def deploy(named_instance, target); end

      desc "caches <named_instance>", "List cached deployments"
      def caches(named_instance); end

      desc "rollback <named_instance> <cache>", "Rollback to a cached deployment"
      def rollback(named_instance, cache); end

      desc "config SUBCOMMAND", "View and manage config"
      subcommand "config", Config

      desc "log SUBCOMMAND", "View and manage logs"
      subcommand "log", Log
    end



  end

end
