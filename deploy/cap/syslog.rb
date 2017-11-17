# frozen_string_literal: true

require "pry"

namespace :syslog do
  def journalctl_cmd(initial: [:sudo, "/bin/journalctl"])
    fetch(:systemd_services).reduce(initial) {|memo, obj| memo + ["-u", obj] }
  end

  def quote(arg)
    '"' + arg.gsub(/(["\\])/, '\\1') + '"'
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
      execute(*journalctl_cmd + ["|", :grep, quote(fetch(:grep_pattern))]) unless fetch(:systemd_services).empty?
    end
  end

  desc "Follow the system log output for the applications's systemd service (Ctrl-C to abort)"
  task :follow do
    on roles(:app) do
      execute(*journalctl_cmd + ["-f"]) unless fetch(:systemd_services).empty?
    end
  end
end
