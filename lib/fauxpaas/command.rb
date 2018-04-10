module Fauxpaas

  # Represetns a command within Fauxpaas
  class Command

    def initialize(options)
      @options = options
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
  end

  class ReadDefaultBranchCommand < Command; end
  class CachesCommand < Command; end
  class ReleasesCommand < Command; end
  class RestartCommand < Command; end
  class SyslogViewCommand < Command; end
  class SyslogFollowCommand < Command; end
  class DeployCommand < Command
    def extra_keys
      [:reference]
    end
  end
  class SetDefaultBranchCommand < Command
    def extra_keys
      [:new_branch]
    end
  end
  class RollbackCommand < Command
    def extra_keys
      [:cache]
    end
  end
  class SyslogGrepCommand < Command
    def extra_keys
      [:pattern]
    end
  end

end
