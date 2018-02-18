module Fauxpaas

  class Command
    def initialize(options)
      @options = options
    end

    def run
      raise NotImplementedError
    end

    def default_keys
      Set.new([:instance_name])
    end

    def extra_keys
      []
    end

    def keys
      default_keys | extra_keys
    end

    def missing
      keys.select{|k| options.send(k).nil? }
    end

    def valid?
      missing.empty?
    end

    def validate!
      unless valid?
        raise KeyError, "Missing keys:\n\t#{missing.join(" :")}"
      end
      self
    end

    private
    attr_reader :options

    def instance
      @instance ||= Fauxpaas.instance_repo.find(options[:instance_name])
    end

    def report(status, action: "action")
      if status.success?
        puts "#{action} successful"
      else
        puts "#{action} failed (run again with --verbose for more info)"
      end
    end
  end

  class DeployCommand < Command
    def run
      signature = instance.signature(options[:reference])
      release = ReleaseBuilder.new(Fauxpaas.filesystem).build(signature)
      status = release.deploy
      report(status, action: "deploy")
      if status.success?
        instance.log_release(LoggedRelease.new(ENV["USER"], Time.now, signature))
        Fauxpaas.instance_repo.save(instance)
        RestartCommand.new(options).run
      end
    end

    private

    def reference
      options.fetch(:reference, instance.default_branch)
    end
  end

  class SetDefaultBranchCommand < Command
    def extra_keys
      [:new_branch]
    end

    def run
      old_branch = instance.default_branch
      instance.default_branch = options[:new_branch]
      Fauxpaas.instance_repo.save(instance)
      puts "Changed default branch from #{old_branch} to #{options[:new_branch]}"
    end
  end

  class ReadDefaultBranchCommand < Command
    def run
      puts "Default branch: #{instance.default_branch}"
    end
  end


  class RollbackCommand < Command
    def extra_keys
      [:cache]
    end

    def run
      report(instance.interrogator
        .rollback(instance.source.latest, options[:cache]),
      action: "rollback")
    end
  end

  class CachesCommand < Command
    def run
      puts instance
        .interrogator
        .caches
    end
  end

  class ReleasesCommand < Command
    def run
      puts instance.releases.map(&:to_s).join("\n")
    end
  end

  class RestartCommand < Command
    def run
      report(instance.interrogator.restart,
        action: "restart")
    end
  end

  class SyslogViewCommand < Command
    def run
      instance.interrogator.syslog_view
    end
  end

  class SyslogGrepCommand < Command
    def extra_keys
      [:pattern]
    end
    def run
      instance.interrogator.syslog_grep(options[:pattern])
    end
  end

  class SyslogFollowCommand < Command
    def run
      instance.interrogator.syslog_follow
    end
  end

end
