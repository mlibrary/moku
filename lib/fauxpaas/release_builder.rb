# frozen_string_literal: true

require "fauxpaas/release_signature"
require "fauxpaas/release"
require "fauxpaas/filesystem"

module Fauxpaas

  # Build a release from a signature
  class ReleaseBuilder

    # @param fs [Filesystem]
    def initialize(fs)
      @fs = fs
    end

    # @param signature [ReleaseSignature]
    # @return [Release]
    def build(signature)
      dir = fs.mktmpdir
      Release.new(
        shared_path: extract_ref(signature.shared, dir/"shared"),
        unshared_path: extract_ref(signature.unshared, dir/"unshared"),
        deploy_config: deploy_config(signature),
        source: signature.source
      )
    end

    private

    attr_reader :fs

    def deploy_config(signature)
      @deploy_config ||= signature.deploy.checkout do |working_dir|
        contents = YAML.safe_load(fs.read(working_dir.dir/"deploy.yml"))
        DeployConfig.from_hash(contents)
      end
    end

    def extract_ref(ref, path)
      fs.mkdir_p path
      add_reference(ref, path)
      path
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

  end
end
