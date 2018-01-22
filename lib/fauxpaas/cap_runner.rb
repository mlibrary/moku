# frozen_string_literal: true

require "fauxpaas/open3_capture"
require "shellwords"

module Fauxpaas

  # Wraps capistrano commands
  class CapRunner
    def initialize(system_runner = Open3Capture.new)
      @system_runner = system_runner
    end

    attr_reader :system_runner

    def run(capfile_path, stage, task, options)
      system_runner.run(
        "cap -f #{capfile_path} #{stage} #{task} --trace " \
          "#{capify_options(options).join(" ")}".strip
      )
    end

    def eql?(other)
      other.is_a?(self.class) &&
        system_runner == other.system_runner
    end

    private

    def capify_options(opts)
      opts.keep_if {|_key, value| value }
        .map {|key, value| "#{key.to_s.upcase}=#{Shellwords.escape(value)}" }
    end

  end

end
