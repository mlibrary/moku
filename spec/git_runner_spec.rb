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
    let(:url) { Pathname.new(__FILE__).dirname/".."/".git" }
    let(:commit) { "00dd3a5a8dbb1c19809cfb1499829defd8e16e49" }

    describe "#sha" do
      let(:local_resolver) { double(:local, sha: "localresult") }
      let(:remote_resolver) { double(:remote, sha: "remoteresult") }
      let(:fs) { MemoryFilesystem.new }
      let(:runner) do
        described_class.new(
          system_runner: double(:system_runner, run: ""),
          local_resolver: local_resolver,
          remote_resolver: remote_resolver,
          fs: fs
        )
      end
      context "repo does not exist on local disk" do
        before(:each) do
          allow(fs).to receive(:exists?).with(url).and_return(false)
        end
        it "resolves the ref remotely" do
          expect(runner.sha(url, commit)).to eql("remoteresult")
        end
      end
      context "repo exists on local disk" do
        before(:each) do
          allow(fs).to receive(:exists?).with(url).and_return(true)
        end
        it "resolves the ref locally" do
          expect(runner.sha(url, commit)).to eql("localresult")
        end
      end
    end

    describe "#safe_checkout" do
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
        it "yields a working_directory with paths of the contents" do
          allow(system_runner).to receive(:run)
            .with(a_string_matching("git ls-files"))
            .and_return(["one.txt\ntwo.txt\n"])
          runner.safe_checkout(url, commit) do |working_dir|
            expect(working_dir.dir).to eql(fs.tmpdir/"fauxpaas")
            expect(working_dir.real_files).to match_array([
              fs.tmpdir/"fauxpaas"/"one.txt",
              fs.tmpdir/"fauxpaas"/"two.txt"
            ])
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
          runner.safe_checkout(url, commit) do |working_dir|
            expect(`git -C #{working_dir.dir} rev-parse HEAD`.strip)
              .to eql(commit)
          end
        end
        it "yields a working_directory" do
          runner.safe_checkout(url, commit) do |working_dir|
            expected = [".gitignore", "Gemfile"]
              .map{|file| Pathname.new(file) }
            expect(working_dir.relative_files).to match_array(expected)
          end
        end
      end

    end
  end
end

