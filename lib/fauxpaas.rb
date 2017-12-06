# frozen_string_literal: true

require "fauxpaas/version"
require "fauxpaas/components"

require "fauxpaas/archive"
require "fauxpaas/cap"
require "fauxpaas/cap_runner"
require "fauxpaas/cli"
require "fauxpaas/deploy_archive"
require "fauxpaas/deploy_config"
require "fauxpaas/file_instance_repo"
require "fauxpaas/filesystem"
require "fauxpaas/git_reference"
require "fauxpaas/git_runner"
require "fauxpaas/infrastructure"
require "fauxpaas/infrastructure_archive"
require "fauxpaas/instance"
require "fauxpaas/kernel_system"
require "fauxpaas/logged_release"
require "fauxpaas/open3_capture"
require "fauxpaas/release"
require "fauxpaas/release_signature"
require "fauxpaas/verbose_runner"

# Fake Platform As A Service
module Fauxpaas
end
