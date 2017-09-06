require "thor"
require "fauxpaas"

module Fauxpaas
  module CLI

    class Var < Thor
      desc "list <named_instance>", "List out the config"
      def list(named_instance)
        #TODO: authz
        Instance.new(named_instance).var_file
          .list
      end

      desc "add <named_instance> <key> <value>",
        "Add a variable on subsequent deploys"
      def add(named_instance, key, value)
        #TODO: authz
        Instance.new(named_instance).var_file
          .add(key, value)
      end

      desc "remove <named_instance> <key>",
        "Cease installing the key to value on subsequent deploys"
      def remove(named_instance, key)
        #TODO: authz
        Instance.new(named_instance).var_file
          .remove(key)
      end
    end

    class File < Thor
      desc "list <named_instance>", "List the files"
      def list(named_instance)
        #TODO: authz
        Instance.new(named_instance).config_files
          .list
      end

      desc "add <named_instance> <app_path>",
        "Add a file to be installed to <app_path> on subsequent deploys"
      def add(named_instance, filename, app_path)
        #TODO: authz
        contents = STDIN.gets
        Instance.new(named_instance).config_files
          .add(filename, app_path, contents)
      end

      desc "remove <named_instance> <app_path>",
        "Cease installing the file to <app_path> on subsequent deploys"
      def remove(named_instance, app_path)
        #TODO: authz
        Instance.new(named_instance).config_files
          .remove(app_path)
      end

      desc "move <named_instance> <app_path> <new_app_path>",
        "Install the file at <app_path> to <new_app_path> instead on subsequent deploys"
      def move(named_instance, app_path, new_app_path)
        #TODO: authz
        Instance.new(named_instance).config_files
          .move(app_path, new_app_path)
      end
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

      desc "var SUBCOMMAND", "View and manage configuration variables"
      subcommand "var", Var

      desc "file SUBCOMMAND", "View and manage configuration files"
      subcommand "file", File

      desc "log SUBCOMMAND", "View and manage logs"
      subcommand "log", Log
    end



  end

end
