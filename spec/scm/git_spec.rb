# frozen_string_literal: true

require_relative "../spec_helper"
require "moku/scm/git"
require "moku/shell/basic"
require "moku/scm/git/local_resolver"
require "moku/scm/git/remote_resolver"

module Moku
  RSpec.describe SCM::Git do
    let(:url) { Pathname.new(__dir__)/".."/".."/".git" }
    let(:commit) { "00dd3a5a8dbb1c19809cfb1499829defd8e16e49" }

    before(:each) do
      Moku.config.register(:logger) { Logger.new(StringIO.new, level: :info) }
    end

    describe "#sha" do
      include FakeFS::SpecHelpers
      let(:local_resolver) { double(:local, sha: "localresult") }
      let(:remote_resolver) { double(:remote, sha: "remoteresult") }
      let(:runner) do
        described_class.new(
          system_runner: double(:system_runner, run: ""),
          local_resolver: local_resolver,
          remote_resolver: remote_resolver
        )
      end

      context "when repo does not exist on local disk" do
        it "resolves the ref remotely" do
          expect(runner.sha(url, commit)).to eql("remoteresult")
        end
      end

      context "when repo exists on local disk" do
        before(:each) do
          FileUtils.mkdir_p(url.dirname.to_s)
          FileUtils.touch(url.to_s)
        end

        it "resolves the ref locally" do
          expect(runner.sha(url, commit)).to eql("localresult")
        end
      end
    end

    describe "#safe_checkout" do
      context "with full mocking" do
        include FakeFS::SpecHelpers
        let(:system_runner) { double(:system_runner, run: "") }
        let(:runner) do
          described_class.new(
            system_runner: system_runner,
            local_resolver: double(:local_resolver),
            remote_resolver: double(:remote_resolver)
          )
        end

        before(:each) do
          allow(system_runner).to receive(:run)
            .with(a_string_matching("git ls-files"))
            .and_return(double(
              :output,
              status?: true,
              error: "",
              output: "one.txt\ntwo.txt\n"
            ))
        end

        it "yields a working_directory with paths of the contents" do
          Dir.mktmpdir do |dir|
            runner.safe_checkout(url, commit, dir) do |working_dir|
              expect(working_dir.dir).to eql(Pathname.new(dir))
              expect(working_dir.real_files).to match_array([
                Pathname.new(dir)/"one.txt",
                Pathname.new(dir)/"two.txt"
              ])
            end
          end
        end
      end

      # Tests that perform a git checkout are broken in travis, so we skip them
      # by applying this label. Please do not skip tests other than those that
      # perform a _real_ git checkout (which should only happen in SCM::Git or
      # its dependencies).
      context "integration", broken_in_travis: true do
        let(:runner) do
          described_class.new(
            local_resolver: SCM::Git::LocalResolver.new(Shell::Basic.new),
            remote_resolver: SCM::Git::RemoteResolver.new(Shell::Basic.new),
            system_runner: Shell::Basic.new
          )
        end

        it "checks out the ref" do
          Dir.mktmpdir do |dir|
            runner.safe_checkout(url, commit, dir) do |working_dir|
              expect(`git -C #{working_dir.dir} rev-parse HEAD`.strip)
                .to eql(commit)
            end
          end
        end
        it "yields a working_directory" do
          Dir.mktmpdir do |dir|
            runner.safe_checkout(url, commit, dir) do |working_dir|
              expected = [".gitignore", "Gemfile"]
                .map {|file| Pathname.new(file) }
              expect(working_dir.relative_files).to match_array(expected)
            end
          end
        end
      end
    end
  end
end
