# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/fake_remote_runner"
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

      ["localhost", "another_localhost"].each_with_index do |host, i|
        context "with host ##{i} at site #1" do
          let(:host) { host }

          it_behaves_like "a successful deploy"
          include_examples "only installs production gems"

          it "links site-specific files" do
            expect(File.read(current_dir/"woot.yml")).to eql("foo: bar\n")
          end

          it "links site-specific nested files" do
            expect(File.read(current_dir/"site"/"only"/"local.txt"))
              .to eql("this file is specific to this site\n")
          end
        end
      end

      context "with a host at site #2" do
        let(:host) { "remote_host" }

        it_behaves_like "a successful deploy"
        include_examples "only installs production gems"

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
          expect((current_dir/"woot.yml").exist?).to be false
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
