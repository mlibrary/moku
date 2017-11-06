# frozen_string_literal: true

require "fauxpaas/open3_capture"

module Fauxpaas
  class CapRunner
    def initialize(capfile_path, system_runner = Open3Capture.new)
      @capfile_path = capfile_path
      @system_runner = system_runner
    end

    attr_reader :capfile_path, :system_runner

    def run(stage, task, options)
      system_runner.run(
        "cap -f #{capfile_path} #{stage} #{task} " \
          "#{capify_options(options).join(" ")}".strip
      )
    end

    def eql?(other)
      other.is_a?(self.class) &&
        capfile_path == other.capfile_path &&
        system_runner == other.system_runner
    end

    private
    def capify_options(opts)
      opts.keep_if {|_key, value| value }
        .map {|key,value| "#{key.to_s.upcase}=#{value}" }
    end
  end

end