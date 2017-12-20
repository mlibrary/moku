# frozen_string_literal: true

require "fauxpaas/release_signature"
require "fauxpaas/release"
require "fauxpaas/filesystem"

module Fauxpaas

  # Build a release from a signature
  class ReleaseBuilder

    # @param signature [ReleaseSignature]
    # @param fs [Filesystem]
    def initialize(signature, fs: Filesystem.new)
      @signature = signature
      @fs = fs
    end

    # @return [Release]
    def build
      Release.new(
        shared_path: extract_shared!,
        unshared_path: extract_unshared!,
        deploy_config: deploy_config,
        source: signature.source
      )
    end

    private

    attr_reader :signature, :fs

    def deploy_config
      @deploy_config ||= signature.deploy.checkout do |working_dir|
        contents = YAML.safe_load(fs.read(working_dir.dir/"deploy.yml"))
        DeployConfig.from_hash(contents)
      end
    end

    def extract_shared!
      fs.mkdir_p(shared_path)
      signature.shared.each {|ref| add_reference(ref, shared_path) }
      shared_path
    end

    def extract_unshared!
      fs.mkdir_p(unshared_path)
      signature.unshared.each {|ref| add_reference(ref, unshared_path) }
      unshared_path
    end

    def add_reference(reference, base)
      reference.checkout do |working_dir|
        working_dir
          .relative_files
          .reject {|path| fs.directory?(path) }
          .map {|file| [working_dir.dir/file, base/file] }
          .each do |src, dest|
            fs.mkdir_p(dest.dirname)
            fs.cp(src, dest)
          end
      end
    end

    def shared_path
      release_dir/"shared"
    end

    def unshared_path
      release_dir/"unshared"
    end

    def release_dir
      @release_dir ||= fs.mktmpdir
    end

  end
end
