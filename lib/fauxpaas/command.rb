# frozen_string_literal: true

# frozen_string_litera: true

module Fauxpaas

  # Represetns a command within Fauxpaas
  class Command
    def initialize(options)
      @options = options
    end

    def execute
      raise NotImplementedError
    end

    def default_keys
      [:instance_name]
    end

    def action
      :none
    end

    def authorized?
      Fauxpaas.auth.authorized?(
        user: options.fetch(:user, "nobody"),
        entity: instance,
        action: action
      )
    end

    def extra_keys
      []
    end

    def keys
      default_keys | extra_keys
    end

    def missing
      keys.select {|k| options[k].nil? }
    end

    def valid?
      missing.empty?
    end

    private

    attr_reader :options

    def instance
      @instance ||= Fauxpaas.instance_repo.find(options[:instance_name])
    rescue Errno::ENOENT
      raise ArgumentError, "The requested instance [#{options[:instance_name]}] doesn't exist"
    end

    def report(status, action: "action")
      if status.success?
        Fauxpaas.logger.info "#{action} successful"
      else
        Fauxpaas.logger.fatal "#{action} failed (run again with --verbose for more info)"
      end
    end
  end

  # Create and deploy a release
  class DeployCommand < Command
    def action
      :deploy
    end

    def execute
      signature = instance.signature(options[:reference])
      release = ReleaseBuilder.new(Fauxpaas.filesystem).build(signature)
      status = release.deploy
      report(status, action: "deploy")
      if status.success?
        instance.log_release(LoggedRelease.new(ENV["USER"], Time.now, signature))
        Fauxpaas.instance_repo.save_releases(instance)
        Fauxpaas.invoker.add_command(RestartCommand.new(options))
      end
    end

    private

    def reference
      options.fetch(:reference, instance.default_branch)
    end
  end

  # Change the instance's default source branch
  class SetDefaultBranchCommand < Command
    def action
      :set_default_branch
    end

    def extra_keys
      [:new_branch]
    end

    def execute
      old_branch = instance.default_branch
      instance.default_branch = options[:new_branch]
      Fauxpaas.instance_repo.save_instance(instance)
      Fauxpaas.logger.info "Changed default branch from #{old_branch} to #{options[:new_branch]}"
    end
  end

  # Show the instance's default source branch
  class ReadDefaultBranchCommand < Command
    def action
      :read_default_branch
    end

    def execute
      Fauxpaas.logger.info "Default branch: #{instance.default_branch}"
    end
  end

  # Rollback to a previous cache
  class RollbackCommand < Command
    def action
      :rollback
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

  # Show the existing caches
  class CachesCommand < Command
    def action
      :caches
    end

    def execute
      Fauxpaas.logger.info instance
        .interrogator
        .caches
    end
  end

  # Show the releases
  class ReleasesCommand < Command
    def action
      :releases
    end

    def execute
      Fauxpaas.logger.info instance.releases.map(&:to_s).join("\n")
    end
  end

  # Restart the application
  class RestartCommand < Command
    def action
      :restart
    end

    def execute
      report(instance.interrogator.restart,
        action: "restart")
    end
  end

  # View the system logs
  class SyslogViewCommand < Command
    def action
      :syslog_view
    end

    def execute
      instance.interrogator.syslog_view
    end
  end

  # Grep the system logs
  class SyslogGrepCommand < Command
    def action
      :syslog_grep
    end

    def extra_keys
      [:pattern]
    end

    def execute
      instance.interrogator.syslog_grep(options[:pattern])
    end
  end

  # tail -f the system logs
  class SyslogFollowCommand < Command
    def action
      :syslog_follow
    end

    def execute
      instance.interrogator.syslog_follow
    end
  end

end
