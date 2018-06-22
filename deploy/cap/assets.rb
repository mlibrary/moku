namespace :deploy do
  namespace :assets do
    task :precompile
    after :precompile, :open_permissions do
      on release_roles(fetch(:assets_roles)) do
        execute(:chmod, "-R", "go+r", File.join(fetch(:deploy_to), "shared", "public", "assets"))
      end
    end
  end
end
