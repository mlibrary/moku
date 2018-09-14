# frozen_string_literal: true

require "fauxpaas/commands/command"
require "fauxpaas/commands/caches"
require "fauxpaas/commands/deploy"
require "fauxpaas/commands/exec"
require "fauxpaas/commands/read_default_branch"
require "fauxpaas/commands/releases"
require "fauxpaas/commands/restart"
require "fauxpaas/commands/rollback"
require "fauxpaas/commands/set_default_branch"
require "fauxpaas/commands/syslog_follow"
require "fauxpaas/commands/syslog_grep"
require "fauxpaas/commands/syslog_view"

module Fauxpaas
  # Contains commands
  module Commands; end
end
