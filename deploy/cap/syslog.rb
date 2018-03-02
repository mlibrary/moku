# frozen_string_literal: true

require "shellwords"

namespace :syslog do
  def journalctl_cmd(journalctl: [:sudo, "/bin/journalctl"])
    journalctl + fetch(:systemd_services).map {|unit| ["-u", Shellwords.escape(unit)] }.flatten
  end

  desc "View the system log for the application's systemd service"
  task :view do
    on roles(:app) do
      execute(*journalctl_cmd) unless fetch(:systemd_services).empty?
    end
  end

  desc "Grep the system log for the application's systemd service (set GREP_PATTERN)"
  task :grep do
    set :grep_pattern, ENV.fetch("GREP_PATTERN", ".")
    on roles(:app) do
      unless fetch(:systemd_services).empty?
        execute(*journalctl_cmd + ["|", :grep, Shellwords.escape(fetch(:grep_pattern))])
      end
    end
  end

  desc "Follow the system log output for the applications's systemd service (Ctrl-C to abort)"
  task :follow do
    on roles(:app) do
      execute(*journalctl_cmd + ["-f"]) unless fetch(:systemd_services).empty?
    end
  end
end
