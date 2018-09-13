# frozen_string_literal: true

require "fauxpaas/artifact"
require "fauxpaas/step_list"
require "pathname"
require "yaml"

module Fauxpaas

  # Builds artifacts
  # @see Artifact
  class ArtifactBuilder
    def initialize(factory:, ref_repo:, runner:)
      @factory = factory
      @ref_repo = ref_repo
      @runner = runner
    end

    # Build an artifact in the system's temporary directory
    # @param signature [ReleaseSignature]
    # @return The result of factory.new, pointing at the path
    def build(signature)
      path = Pathname.new(Dir.mktmpdir)
      add_references!(signature, path)
      install_local_gems(path)
      finish_build!(path)
			set_access_control(path)
      factory.new(path)
    end

    private

    attr_reader :factory, :ref_repo, :runner

    # Download the references from the signature and copy them
    # into the artifact's path.
    def add_references!(signature, path)
      [signature.source, signature.shared, signature.unshared].each do |ref|
        add_reference(ref, path)
      end
    end

    def add_reference(ref, path)
      ref_repo.resolve(ref)
        .cp(path)
        .write
    end

    def install_local_gems(path)
      Bundler.with_clean_env do
        Dir.chdir(path) do
          _, _, status = Fauxpaas.system_runner.run(
            "bundle install --deployment '--without=development test'"
          )
          raise "bundler failed to install gems in #{path}" unless status.success?
        end
      end
    end

    # Run the finish_build commands, if they exist. Should any fail,
    # halt the build and raise an error.
    def finish_build!(path)
      steps_path = path/"finish_build.yml"
      if steps_path.exist?
        step_list = StepList.new(YAML.safe_load(File.read(steps_path)))
        Dir.chdir(path) do
          step_list.steps.each do |step|
            _, _, status = runner.run(step.cmd)
            raise "failure in finish_build command" unless status.success?
          end
        end
      end
    end

		# Set the mode bits on all files in the Artifact
		# @param path [Pathname]
		# @param asset_dir [String]
		def set_access_control(path, asset_dir = "public")
			asset_path = path/asset_dir

      # Set permissions on artifact
      if Dir.exist?(path)
        Find.find(path) do |found_path|
          if File.directory?(found_path)
            FileUtils.chmod(2770, found_path)
          else
            FileUtils.chmod(0660, found_path)
          end
        end
      end

      # If asset directory exists set permissions on it also
      if Dir.exists?(asset_path)
        Find.find(asset_path) do |found_path|
          if File.directory?(found_path)
            FileUtils.chmod(2775, found_path)
          else
            FileUtils.chmod(0664, found_path)
          end
        end
      end

    end

  end
end
