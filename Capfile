
# Change cap's default paths
set :deploy_config_path, File.expand_path("deploy/deploy.rb")
set :stage_config_path, File.expand_path("deploy/stages")


# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load the SCM plugin appropriate to your project:
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
require "capistrano/rbenv"
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"

# Load custom tasks from `deploy/tasks` if you have any defined
Dir.glob("deploy/tasks/*.rake").each { |r| import r }
