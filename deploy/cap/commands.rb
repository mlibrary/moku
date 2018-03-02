namespace :commands do
  task :run do
    on roles(:all) do |host|
      within fetch(:release_path) do
        after_build_file = File.join(fetch(:release_path), "after_build.yml")
        roles_array = host.roles_array.map{|r| r.to_s }
        if File.exist? after_build_file
          YAML.load_file(after_build_file)
            .reject{|cmd| (roles_array & cmd["roles"]).empty? }
            .each {|cmd| execute cmd["bin"], cmd["opts"] }
        end
      end
    end
  end
end
after "deploy:updated", "commands:run"
