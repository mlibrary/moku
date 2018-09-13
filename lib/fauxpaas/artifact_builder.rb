# frozen_string_literal: true

require "fauxpaas/artifact"
require "pathname"
require "pry"

module Fauxpaas

  # Builds artifacts
  # @see Artifact
  class ArtifactBuilder
    def initialize(ref_repo:, factory:)
      @ref_repo = ref_repo
      @factory = factory
    end

    # Build an artifact in the system's temporary directory
    # @param signature [ReleaseSignature]
    # @return The result of factory.new, pointing at the path
    def build(signature)
      @artifact = factory.new

      add_references!(signature)
      run_command("/usr/bin/env")
      run_command("bundle install --deployment --without development test --path vendor/bundle")
      run_command("bundle exec rake assets:precompile RAILS_ENV=production")

      binding.pry

      @artifact
    end

    attr_reader :artifact

    private

    attr_reader :ref_repo, :factory

    def add_references!(signature)
      [signature.source, signature.shared, signature.unshared].each do |ref|
        merge_path(ref_repo.resolve(ref),artifact.path)
      end
    end

    def run_command(command)
      Dir.chdir(artifact.path.to_s) do
        Bundler.with_clean_env do
          Fauxpaas.system_runner.run(command)
        end
      end
    end

    def merge_path(source,dst)
      source
        .cp(dst)
        .write
    end

  end
end
