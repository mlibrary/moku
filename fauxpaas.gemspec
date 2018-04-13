# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fauxpaas/version"

Gem::Specification.new do |spec|
  spec.name          = "fauxpaas-client"
  spec.version       = Fauxpaas::VERSION
  spec.authors       = ["Bryan Hockey"]
  spec.email         = ["bhock@umich.edu"]

  spec.summary       = "fauxpaas-client"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "canister"
  spec.add_runtime_dependency "ettin", "~> 1.1.0"
  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "thor-hollaback"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov"
end
