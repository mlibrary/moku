require "thor"
require "fauxpaas"

module Fauxpaas
  module CLI

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

  end
end
