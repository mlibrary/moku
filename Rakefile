# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

desc "Run unit tests"
RSpec::Core::RakeTask.new("spec:unit") do |task|
  task.pattern = "./spec/**/*_spec.rb"
  task.rspec_opts = "--tag ~integration"
end

desc "Run integration tests"
task "spec:integration" do
  puts "This seems to break rspec"
  puts "Specify the filename explicitly for now:"
  puts "bundle exec rspec spec/integration_spec.rb"
end

desc "Run unit tests [default]"
task test: "spec:unit"

task default: "spec:unit"
