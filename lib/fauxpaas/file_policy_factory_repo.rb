require "fileutils"
require "erb"
require "pathname"
require "yaml"
require "fauxpaas/policy_factory"
require "fauxpaas/policy"

module Fauxpaas

  # Loads and saves role information used by policy factories.
  class FilePolicyFactoryRepo
    def initialize(instances_root, policy_type: Policy)
      @instances_root = Pathname.new(instances_root)
      @policy_type = policy_type
    end

    def find
      all = load_file(top_path)
      instances = Dir[instances_root/"*"/"permissions.yml"]
        .map{|path| Pathname.new(path) }
        .map{|path| [path.dirname.basename.to_s, load_file(path)] }
        .to_h
      PolicyFactory.new(
        policy_type: policy_type,
        all: all,
        instances: instances
      )
    end

    def save(factory)
      FileUtils.mkdir_p instances_root
      File.write(instances_root/"permissions.yml", YAML.dump(factory.send(:all)))

      factory.send(:instances).each_pair do |name, data|
        FileUtils.mkdir_p instance_path(name).dirname
        File.write(instance_path(name), YAML.dump(data))
      end

    end

    private
    attr_reader :instances_root, :policy_type

    def load_file(path)
      if path.exist?
        YAML.safe_load(ERB.new(File.read(path)).result) || {}
      else
        {}
      end
    end

    def top_path
      instances_root/"permissions.yml"
    end

    def instance_path(name)
      instances_root/name/"permissions.yml"
    end

  end
end
