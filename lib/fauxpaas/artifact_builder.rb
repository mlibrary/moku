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
      finish_build!(path)
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

  end
end
