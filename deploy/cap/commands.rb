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
end
