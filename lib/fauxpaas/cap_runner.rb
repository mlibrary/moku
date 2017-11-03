# frozen_string_literal: true

require "fauxpaas/open3_capture"

module Fauxpaas
  class CapRunner
    def initialize(capfile_path, runner = Open3Capture.new)
      @capfile_path = capfile_path
      @runner = runner
    end

    def run(stage, task, options)
      runner.run(
        "cap -f #{capfile_path} #{stage} #{task} #{capify_options(options).join(" ")}".strip
      )
    end

    def eql?(other)
      other.is_a?(self.class) &&
        self.capfile_path == other.capfile_path
    end

    private
    attr_reader :capfile_path, :runner

    def capify_options(opts)
      opts.keep_if {|_key, value| value }
        .map {|key,value| "#{key.to_s.upcase}=#{value}" }
    end
  end

end
