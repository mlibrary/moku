# frozen_string_literal: true

require "moku/pipeline/pipeline"
require "moku/pipeline/caches"
require "moku/pipeline/deploy"
require "moku/pipeline/exec"
require "moku/pipeline/init"
require "moku/pipeline/read_default_branch"
require "moku/pipeline/releases"
require "moku/pipeline/rollback"
require "moku/pipeline/set_default_branch"

module Moku

  # Namespace and factory for pipelines
  module Pipeline; end
end
