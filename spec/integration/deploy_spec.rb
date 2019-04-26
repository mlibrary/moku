# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/with_a_sandbox"
require_relative "../support/with_a_deployed_instance"
require_relative "../support/a_successful_deploy"
require_relative "../support/with_context"
require "open3"
require "pathname"

module Moku

  RSpec.describe "integration deploy", integration: true do
    context "without rails" do
      include_context "with a sandbox", "test-norails"
      include_context "with a deployed instance", "test-norails"
      let(:gem) { "pry" }
      let(:development_gem) { "faker" }
      let(:test_gem) { "rspec" }
      let(:source) { Pathname.new("some_source_file.txt") }
      let(:deploy_dir) { deploy_root/host/"my"/"deploy"/"dir" } # see deploy.yml fixture
      let(:current_dir) { deploy_dir/"current" }

      RSpec.shared_examples "only installs production gems" do
        it "doesn't install development gems" do
          within(current_dir) do |env|
            expect(`#{env} bundle list`).not_to match(/#{development_gem}/)
          end
        end

        it "doesn't install test gems" do
          within(current_dir) do |env|
            expect(`#{env} bundle list`).not_to match(/#{test_gem}/)
          end
        end
      end

      RSpec.shared_examples "links site-specific files" do
        it "links site-specific files" do
          expect(File.read(current_dir/"woot.yml")).to eql("foo: overwritten\n")
        end

        it "links site-specific nested files" do
          expect(File.read(current_dir/"site"/"only"/"local.txt"))
            .to eql("this file is specific to this site\n")
        end

        # Other sites have no infrastructure.yml, so will skip this
        it "creates a symlink for each dir in infrastructure.yml's path stanza" do
          expect((current_dir/"tmp").readlink).to eql(Pathname.new("/tmp/test-norails"))
          expect((current_dir/"data").readlink).to eql(Pathname.new("/data"))
        end

        # This test relies on the presence of path.log/ in the norails infrastructure.yml fixture,
        # and the presence of the log symlink and target in the norails source repo fixture.
        it "does not follow links when removing existing tmp directory" do
          expect((current_dir/"target_of_log"/"important.log").exist?).to be true
        end
      end

      context "with host #1 at site #1" do
        let(:host) { "localhost" }

        it_behaves_like "a successful deploy"
        include_examples "only installs production gems"
        include_examples "links site-specific files"

        it "receives commands run against all hosts" do
          expect((current_dir/"every_host").exist?).to be true
        end

        it "receives commands run against each site" do
          expect((current_dir/"each_site").exist?).to be true
        end

        it "receives commands run once per deploy" do
          expect((current_dir/"just_once").exist?).to be true
        end
      end

      context "with host #2 at site #1" do
        let(:host) { "another_localhost" }

        it_behaves_like "a successful deploy"
        include_examples "only installs production gems"
        include_examples "links site-specific files"

        it "receives commands run against all hosts" do
          expect((current_dir/"every_host").exist?).to be true
        end

        it "does not receive commands run against each site" do
          expect((current_dir/"each_site").exist?).to be false
        end

        it "does not receive commands run once per deploy" do
          expect((current_dir/"just_once").exist?).to be false
        end
      end

      context "with a host at site #2" do
        let(:host) { "remote_host" }

        it_behaves_like "a successful deploy"
        include_examples "only installs production gems"

        it "receives commands run against all hosts" do
          expect((current_dir/"every_host").exist?).to be true
        end

        it "receives commands run against each site" do
          expect((current_dir/"each_site").exist?).to be true
        end

        it "does not receive commands run once per deploy" do
          expect((current_dir/"just_once").exist?).to be false
        end

        it "doesn't install development gems" do
          within(current_dir) do |env|
            expect(`#{env} bundle list`).not_to match(/#{development_gem}/)
          end
        end

        it "doesn't install test gems" do
          within(current_dir) do |env|
            expect(`#{env} bundle list`).not_to match(/#{test_gem}/)
          end
        end

        it "does not link files from another site" do
          expect(File.read(current_dir/"woot.yml")).to eql("foo: not overwritten\n")
        end

        it "does not link nested files from another site" do
          expect((current_dir/"site"/"only"/"local.txt").exist?).to be false
        end
      end
    end

    context "with rails" do
      include_context "with a sandbox", "test-rails"
      include_context "with a deployed instance", "test-rails"
      let(:gem) { "rails" }
      let(:source) { Pathname.new("config/environment.rb") }
      let(:deploy_dir) { deploy_root/host/"deploy"/"here" }
      let(:current_dir) { deploy_dir/"current" }

      RSpec.shared_examples "a deployed rails project" do
        it "current/public/assets 2775" do
          expect(current_dir/"public"/"assets").to have_permissions("2775")
        end

        it "current/bin/rails 6770" do
          expect(current_dir/"bin"/"rails").to have_permissions("6770")
        end

        it "installs a working project" do
          within(current_dir) do |env|
            _, _, status = Open3.capture3(
              "#{env} bin/rails runner -e production 'Post.new.valid?'"
            )
            expect(status.success?).to be true
          end
        end
      end

      context "with the primary host at site #1" do
        let(:host) { "localhost" }

        it_behaves_like "a successful deploy"
        it_behaves_like "a deployed rails project"
        it "runs the migrations" do
          expect(`sqlite3 #{current_dir/"db"/"production.sqlite3"} ".schema posts"`.chomp)
            .to match(/CREATE TABLE (IF NOT EXISTS )?"posts"/)
          expect(`sqlite3 #{current_dir/"db"/"production.sqlite3"} ".schema things"`.chomp)
            .to match(/CREATE TABLE (IF NOT EXISTS )?"things"/)
        end

        # This test relies on the presence of path.log in the rails infrastructure.yml fixture,
        # and the presence of the log directory in the rails source repo fixture.
        it "creates a symlink even if the directory already exists" do
          expect((current_dir/"log").readlink).to eql(Pathname.new("/log-rails"))
        end
      end

      context "with a secondary host at site #1" do
        let(:host) { "another_localhost" }

        it_behaves_like "a successful deploy"
        it_behaves_like "a deployed rails project"
        it "does not run migrations" do
          expect((current_dir/"db"/"production.sqlite3").exist?).to be false
        end
      end

      context "with a host at site #2" do
        let(:host) { "remote_host" }

        it_behaves_like "a successful deploy"
        it_behaves_like "a deployed rails project"
        it "does not run migrations" do
          expect((current_dir/"db"/"production.sqlite3").exist?).to be false
        end
      end
    end
  end
end
