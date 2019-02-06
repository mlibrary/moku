# frozen_string_literal: true

require "moku/sequence"
require "tmpdir"

module Moku
  # Adds files from the given directory to a new commit
  # on the given branch in the given remote git repo.
  class Push

    def initialize(dir:, repo:, branch:, runner: Moku.system_runner)
      @dir = dir
      @repo = repo
      @branch = branch
      @runner = runner
    end

    def call
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          Sequence.for([
            "git clone -q --depth 1 #{repo} .",
            "git checkout -q -b #{branch}",
            "cp -R #{dir}/* .",
            "git add .",
            "git commit -q -m 'prefaux pushed'",
            "git push -q -u origin #{branch}"
          ]) {|command| runner.run(command) }
        end
      end
    end

    private

    attr_reader :dir, :repo, :branch, :runner

  end
end
