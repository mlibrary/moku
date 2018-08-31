# frozen_string_literal: true

module Fauxpaas

  # Represetns a command within Fauxpaas
  class Command
    def initialize(instance_name:, user:)
      @instance_name = instance_name
      @user = user
    end

    def execute
      raise NotImplementedError
    end

    def action
      :none
    end

    def authorized?
      Fauxpaas.auth.authorized?(
        user: user || "nobody",
        entity: instance,
        action: action
      )
    end

    private

    attr_reader :instance_name, :user

    def instance
      @instance ||= Fauxpaas.instance_repo.find(instance_name)
    rescue Errno::ENOENT
      raise ArgumentError, "The requested instance [#{instance_name}] doesn't exist"
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
    def initialize(instance_name:, user:, reference: nil)
      super(instance_name: instance_name, user: user)
      @reference = reference
    end

    def action
      :deploy
    end

    def execute
      signature = instance.signature(reference)
      release = ReleaseBuilder.new(Fauxpaas.filesystem).build(signature)
      status = release.deploy
      report(status, action: "deploy")
      if status.success?
        instance.log_release(LoggedRelease.new(user, Time.now, signature))
        Fauxpaas.instance_repo.save_releases(instance)
        Fauxpaas.invoker.add_command(
          RestartCommand.new(instance_name: instance_name, user: user)
        )
      end
    end

    private

    def reference
      @reference || instance.default_branch
    end
  end

  # Change the instance's default source branch
  class SetDefaultBranchCommand < Command
    def initialize(instance_name:, user:, new_branch:)
      super(instance_name: instance_name, user: user)
      @new_branch = new_branch
    end

    attr_reader :new_branch

    def action
      :set_default_branch
    end

    def execute
      old_branch = instance.default_branch
      instance.default_branch = new_branch
      Fauxpaas.instance_repo.save_instance(instance)
      Fauxpaas.logger.info "Changed default branch from #{old_branch} to #{new_branch}"
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
    def initialize(instance_name:, user:, cache:)
      super(instance_name: instance_name, user: user)
      @cache = cache
    end

    attr_reader :cache

    def action
      :rollback
    end

    def execute
      report(instance.interrogator
        .rollback(instance.source.latest, cache),
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
    def initialize(instance_name:, user:, long: false)
      super(instance_name: instance_name, user: user)
      @long = long
    end

    attr_reader :long

    def action
      :releases
    end

    def execute
      string = if long
        LoggedReleases.new(instance.releases).to_s
      else
        LoggedReleases.new(instance.releases).to_short_s
      end

      Fauxpaas.logger.info "\n#{string}"
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

  # Run an arbitrary command
  class ExecCommand < Command
    def initialize(instance_name:, user:, env: {}, role:, bin:, args: [])
      super(instance_name: instance_name, user: user)
      @env = env
      @role = role
      @bin = bin
      @args = args
    end

    attr_reader :env, :role, :bin, :args

    def action
      :exec
    end

    def execute
      report(instance
        .interrogator
        .exec(
          env: env,
          role: role,
          bin: bin,
          args: args.join(" ")
        )
      )
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
    def initialize(instance_name:, user:, pattern:)
      super(instance_name: instance_name, user: user)
      @pattern = pattern
    end

    attr_reader :pattern

    def action
      :syslog_grep
    end

    def execute
      instance.interrogator.syslog_grep(pattern)
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
