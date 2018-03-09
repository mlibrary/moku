module Fauxpaas

  # Represetns a command within Fauxpaas
  class Command
    def initialize(options, policy)
      @options = options
      @policy = policy
    end

    # Run only the logic of the command
    def execute
      raise NotImplementedError
    end

    # Validate, authorize, and execute the command
    def run
      validate!
      authorize!
      execute
    end

    def default_keys
      Set.new([:instance_name])
    end

    def authorized?
      raise NotImplementedError
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

    def authorize!
      unless authorized?
        STDERR.puts "You are not authorized to perform this command"
        exit 6
      end
      self
    end

    def validate!
      unless valid?
        raise KeyError, "Missing keys:\n\t#{missing.join(" :")}"
      end
      self
    end

    private
    attr_reader :options, :policy

    def instance
      begin
        @instance ||= Fauxpaas.instance_repo.find(options[:instance_name])
      rescue Errno::ENOENT
        STDERR.puts "The requested instance [#{options[:instance_name]}] doesn't exist"
      end
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
    def authorized?
      policy.deploy?
    end

    def execute
      signature = instance.signature(options[:reference])
      release = ReleaseBuilder.new(Fauxpaas.filesystem).build(signature)
      status = release.deploy
      report(status, action: "deploy")
      if status.success?
        instance.log_release(LoggedRelease.new(ENV["USER"], Time.now, signature))
        Fauxpaas.instance_repo.save(instance)
        RestartCommand.new(options, policy).run
      end
    end

    private

    def reference
      options.fetch(:reference, instance.default_branch)
    end
  end

  class SetDefaultBranchCommand < Command
    def authorized?
      policy.set_default_branch?
    end

    def extra_keys
      [:new_branch]
    end

    def execute
      old_branch = instance.default_branch
      instance.default_branch = options[:new_branch]
      Fauxpaas.instance_repo.save(instance)
      puts "Changed default branch from #{old_branch} to #{options[:new_branch]}"
    end
  end

  class ReadDefaultBranchCommand < Command
    def authorized?
      policy.read_default_branch?
    end

    def execute
      puts "Default branch: #{instance.default_branch}"
    end
  end


  class RollbackCommand < Command
    def authorized?
      policy.rollback?
    end

    def extra_keys
      [:cache]
    end

    def execute
      report(instance.interrogator
        .rollback(instance.source.latest, options[:cache]),
      action: "rollback")
    end
  end

  class CachesCommand < Command
    def authorized?
      policy.caches?
    end

    def execute
      puts instance
        .interrogator
        .caches
    end
  end

  class ReleasesCommand < Command
    def authorized?
      policy.releases?
    end

    def execute
      puts instance.releases.map(&:to_s).join("\n")
    end
  end

  class RestartCommand < Command
    def authorized?
      policy.restart?
    end

    def execute
      report(instance.interrogator.restart,
        action: "restart")
    end
  end

  class SyslogViewCommand < Command
    def authorized?
      policy.syslog_view?
    end

    def execute
      instance.interrogator.syslog_view
    end
  end

  class SyslogGrepCommand < Command
    def authorized?
      policy.syslog_grep?
    end

    def extra_keys
      [:pattern]
    end
    def execute
      instance.interrogator.syslog_grep(options[:pattern])
    end
  end

  class SyslogFollowCommand < Command
    def authorized?
      policy.syslog_follow?
    end

    def execute
      instance.interrogator.syslog_follow
    end
  end

end
