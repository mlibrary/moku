module Fauxpaas

  # Represetns a command within Fauxpaas
  class Command

    def initialize(options)
      @options = options
    end

    def bin
      "help"
    end

    def execute
      Fauxpaas.system_runner.run(ssh_command)
    end

    def default_keys
      [:instance_name]
    end

    def extra_keys
      []
    end

    def keys
      default_keys | extra_keys
    end

    def missing
      keys.select{|k| options[k].nil? }
    end

    def valid?
      missing.empty?
    end

    private
    attr_reader :options

    def ssh_command
      "ssh #{Fauxpaas.server} #{bin} #{options[:instance_name]} #{extra_keys.map{|k| options[k]}.join(" ")}"
    end
  end

  class ReadDefaultBranchCommand < Command
    def bin
      "default_branch"
    end
  end
  class CachesCommand < Command
    def bin
      "caches"
    end
  end
  class ReleasesCommand < Command
    def bin
      "releases"
    end
  end
  class RestartCommand < Command
    def bin
      "restart"
    end
  end
  class SyslogViewCommand < Command
    def bin
      "syslog view"
    end
  end
  class SyslogFollowCommand < Command
    def bin
      "syslog follow"
    end
  end
  class DeployCommand < Command
    def bin
      "deploy"
    end
    def extra_keys
      [:reference]
    end
  end
  class SetDefaultBranchCommand < Command
    def bin
      "default_branch"
    end
    def extra_keys
      [:new_branch]
    end
  end
  class RollbackCommand < Command
    def bin
      "rollback"
    end
    def extra_keys
      [:cache]
    end
  end
  class SyslogGrepCommand < Command
    def bin
      "syslog grep"
    end
    def extra_keys
      [:pattern]
    end
  end

end
