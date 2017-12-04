require_relative "./spec_helper"
require_relative "./support/memory_filesystem"
require "fauxpaas/git_runner"
require "fauxpaas/open3_capture"
require "fauxpaas/local_git_resolver"
require "fauxpaas/remote_git_resolver"
require "pathname"
require "tmpdir"

module Fauxpaas
  RSpec.describe GitRunner do
    describe "#safe_checkout" do
      let(:url) { Pathname.new(__FILE__).dirname/".."/".git" }
      let(:commit) { "00dd3a5a8dbb1c19809cfb1499829defd8e16e49" }

      context "fully mocked" do
        let(:system_runner) { double(:system_runner, run: "") }
        let(:fs) { MemoryFilesystem.new }
        let(:runner) do
          described_class.new(
            system_runner: system_runner,
            local_resolver: double(:local_resolver),
            remote_resolver: double(:remote_resolver),
            fs: fs
          )
        end
        it "yields a tmp dir" do
          runner.safe_checkout(url, commit) do |dir|
            expect(dir).to eql(fs.tmpdir + "fauxpaas")
          end
        end
      end

      context "integration" do
        let(:runner) do
          described_class.new(
            local_resolver: LocalGitResolver.new(Open3Capture.new),
            remote_resolver: RemoteGitResolver.new(Open3Capture.new),
            system_runner: Open3Capture.new
          )
        end
        it "checks out the ref", broken_in_travis: true do
          runner.safe_checkout(url, commit) do |dir|
            expect(`git -C #{dir} rev-parse HEAD`.strip)
              .to eql(commit)
          end
        end
        it "yields a WorkingDirectory" do
          runner.safe_checkout(url, commit) do |dir|
            expect(dir.files).to match_array(
              `git -C #{dir} ls-files`
                .split("\n")
                .map{|f| Pathname.new(f)}
            )
          end
        end
      end

    end
  end
end

