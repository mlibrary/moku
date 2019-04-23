# frozen_string_literal: true

require_relative "with_context"

module Moku
  # Expects
  # let(:gem) { some gem name }
  # let(:source) { some source file relative path }
  # let(:deploy_root) { path to the deploy root }
  # let(:deploy_dir) { path to the releases/id dir where files actually live }
  # let(:current_dir) { path to the 'current' symlink, likely deploy_dir/current }
  RSpec.shared_examples "a successful deploy" do
    it "the 'releases' dir exists" do
      expect((deploy_dir/"releases").exist?).to be true
    end
    it "the 'current' dir exists" do
      expect(current_dir.exist?).to be true
    end
    it "installs dev files" do
      expect(File.read(current_dir/"some"/"dev"/"file.txt")).to eql("with some dev contents\n")
    end
    it "installs infrastructure files" do
      expect(File.read(current_dir/"some"/"infrastructure"/"file.txt"))
        .to eql("with some infrastructure contents\n")
    end
    it "bundles gems in ./vendor/bundle" do
      expect(File.read(current_dir/".bundle"/"config"))
        .to match(/^BUNDLE_PATH: "vendor\/bundle"$/)
    end
    it "freezes the gems" do
      expect(File.read(current_dir/".bundle"/"config"))
        .to match(/^BUNDLE_FROZEN: "true"$/)
    end

    describe "permissions" do
      it "releases 755" do
        expect(deploy_dir/"releases").to have_permissions("755")
      end
      it "releases/<release> 755" do
        release_dir = (deploy_dir/"releases").children.first
        expect(release_dir).to have_permissions("755")
      end
      it "current/public 755" do
        expect(current_dir/"public").to have_permissions("755")
      end
      it "current/public/<file> 644" do
        file = (current_dir/"public").children.find(&:file?)
        expect(file).to have_permissions("644")
      end
      it "current/<some_dev> 640" do
        file = current_dir/"some"/"dev"/"file.txt"
        expect(file).to have_permissions("640")
      end
      it "current/<some_infrastructure> 640" do
        file = current_dir/"some"/"infrastructure"/"file.txt"
        expect(file).to have_permissions("640")
      end
      it "current/log 750" do
        dir = current_dir/"log"
        expect(dir.exist?).to be true
        expect(dir.directory?).to be true
        expect(dir).to have_permissions("750")
      end
    end

    it "runs finish_build commands" do
      expect((current_dir/"eureka_2.txt").exist?).to be true
      expect(File.read(current_dir/"eureka_1.txt")).to eql("eureka!\n")
    end
    it "installs the gems" do
      # The expect {}-to-output syntax didn't like this test
      within(current_dir) do |env|
        expect(`#{env} bundle list`).to match(/#{gem}/)
      end
    end
    it "installs the source files" do
      expect((current_dir/source).exist?)
        .to be true
    end
  end
end
