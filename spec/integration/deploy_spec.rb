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

  RSpec.describe "deploy integration", integration: true do
    describe "deploy" do
      context "without rails" do
        include_context "with a sandbox", "test-norails"
        include_context "with a deployed instance", "test-norails"
        let(:gem) { "pry" }
        let(:development_gem) { "faker" }
        let(:test_gem) { "rspec" }
        let(:source) { Pathname.new("some_source_file.txt") }

        it_behaves_like "a successful deploy"

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

      context "with rails" do
        include_context "with a sandbox", "test-rails"
        include_context "with a deployed instance", "test-rails"
        let(:gem) { "rails" }
        let(:source) { Pathname.new("config/environment.rb") }

        it_behaves_like "a successful deploy"

        it "current/public/assets 2775" do
          expect(current_dir/"public"/"assets").to have_permissions("2775")
        end

        it "current/bin/rails 6770" do
          expect(current_dir/"bin"/"rails").to have_permissions("6770")
        end

        it "runs the migrations" do
          expect(`sqlite3 #{current_dir/"db"/"production.sqlite3"} ".schema posts"`.chomp)
            .to match(/CREATE TABLE (IF NOT EXISTS )?"posts"/)
          expect(`sqlite3 #{current_dir/"db"/"production.sqlite3"} ".schema things"`.chomp)
            .to match(/CREATE TABLE (IF NOT EXISTS )?"things"/)
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
    end
  end
end
