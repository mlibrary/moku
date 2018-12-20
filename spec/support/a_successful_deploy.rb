# frozen_string_literal: true

require_relative "with_context"

module Moku
  # Expects
  # let(:gem) { some gem name }
  # let(:source) { some source file relative path }
  # let(:deploy_root) { path to the deploy root }
  # let(:current_dir) { path to the 'current' symlink, likely deploy_root/current }
  RSpec.shared_examples "a successful deploy" do
    it "the 'releases' dir exists" do
      expect((deploy_root/"releases").exist?).to be true
    end
    it "the 'current' dir exists" do
      expect(current_dir.exist?).to be true
    end
    it "installs unshared files" do
      expect(File.read(current_dir/"some"/"dev"/"file.txt")).to eql("with some dev contents\n")
    end
    it "installs shared files" do
      expect(File.read(current_dir/"some"/"shared"/"file.txt"))
        .to eql("with some shared contents\n")
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
      it "releases 2775" do
        expect(deploy_root/"releases").to have_permissions("2775")
      end
      it "releases/<release> 2775" do
        release_dir = (deploy_root/"releases").children.first
        expect(release_dir).to have_permissions("2775")
      end
      it "current/public 2775" do
        expect(current_dir/"public").to have_permissions("2775")
      end
      it "current/public/<file> 664" do
        file = (current_dir/"public").children.find(&:file?)
        expect(file).to have_permissions("664")
      end
      it "current/<some_unshared> 660" do
        file = current_dir/"some"/"dev"/"file.txt"
        expect(file).to have_permissions("660")
      end
      it "current/<some_shared_file> 660" do
        file = current_dir/"some"/"shared"/"file.txt"
        expect(file).to have_permissions("660")
      end
      it "current/log 2770" do
        dir = current_dir/"log"
        expect(dir.exist?).to be true
        expect(dir.directory?).to be true
        expect(dir).to have_permissions("2770")
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
