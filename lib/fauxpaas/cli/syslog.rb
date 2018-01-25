# frozen_string_literal: true

require "thor"
require "fauxpaas"

module Fauxpaas
  module CLI

    # Main commands of the cli
    class Syslog < Thor

      desc "view <instance>",
        "View the system logs for the instance"
      def view(instance_name)
        instance = Fauxpaas.instance_repo.find(instance_name)
        instance.interrogator.syslog_view
      end

      desc "grep <instance> pattern",
        "View the system logs for the instance"
      def grep(instance_name, pattern = ".")
        instance = Fauxpaas.instance_repo.find(instance_name)
        instance.interrogator.syslog_grep(pattern)
      end

      desc "follow <instance>",
        "Follow the system logs for the instance"
      def follow(instance_name)
        instance = Fauxpaas.instance_repo.find(instance_name)
        instance.interrogator.syslog_follow
      end

    end

  end
end
