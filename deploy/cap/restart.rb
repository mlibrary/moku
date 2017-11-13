# frozen_string_literal: true

namespace :systemd do
  desc "Restart the application's systemd service"
  task :restart do
    set :systemd_services, ENV.fetch("SYSTEMD_SERVICES", "").split(":")
    fetch(:systemd_services).each do |service|
      on roles(:app) do
        execute :sudo, "/bin/systemctl", "restart", service
      end
    end
  end
end
