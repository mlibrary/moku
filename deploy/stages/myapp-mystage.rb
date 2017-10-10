set :application, "myapp-mystage"
set :repo_url, "git@github.com:mlibrary/myapp.git"
set :branch, "master"
set :deploy_to, "/some/place/we/deploy/myapp"
set :rails_env, "production"
set :assets_prefix, "myapp"

server "appserver.umdl.umich.edu", roles: %w(app)
