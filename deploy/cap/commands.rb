namespace :commands do
  task :run do
    on roles(:all) do |host|
      within fetch(:release_path) do
        roles_array = host.roles_array.map{|r| r.to_s }
        if File.exist?("after_build.yml")
          YAML.load("after_build.yml")
            .reject{|cmd| (roles_array & cmd["roles"]).empty? }
            .each { execute cmd["bin"], cmd["opts"] }
        end
      end
    end
  end
end
after "deploy:updated", "commands:run"
