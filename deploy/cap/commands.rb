namespace :commands do
  task :run_one do
    role = (ENV["FAUX_ROLE"] || :none).to_sym
    bin = ENV["FAUX_BIN"].to_sym
    args = ENV["FAUX_ARGS"]
    env = ENV["FAUX_VARS"].split(":")
      .map{|pair| pair.split("=")}
      .map{|pair| [pair.first.to_sym, pair.last] }
      .to_h
    on roles(role) do
      within fetch(:deploy_to) do
        within 'current' do
          with(env) do
            execute bin, args
          end
        end
      end
    end
  end

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
