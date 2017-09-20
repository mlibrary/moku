require "thor"
require "fauxpaas"

module Fauxpaas
  module CLI

    class Log < Thor
      desc "grep <named_instance> <pattern> <log>", "Grep a log file for the given regex"
      def grep(named_instance, pattern, log); end

      desc "tail <named_instance> <log>", "Tail a log file"
      def tail(named_instance, log); end

      desc "cat <named_instance> <log>", "Display a log file"
      option aliases: [:display, :show]
      def cat(named_instance, log); end
    end

  end
end
