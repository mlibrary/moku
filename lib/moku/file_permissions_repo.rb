# frozen_string_literal: true

require "erb"
require "fileutils"
require "pathname"
require "yaml"

module Moku

  # Loads and saves role information used by the auth service.
  class FilePermissionsRepo
    def initialize(instances_root)
      @instances_root = Pathname.new(instances_root)
    end

    def find
      all = load_file(top_path)
      instances = Dir[instances_root/"*"/"permissions.yml"]
        .map {|path| Pathname.new(path) }
        .map {|path| [path.dirname.basename.to_s, load_file(path)] }
        .to_h
      {
        all:       all,
        instances: instances
      }
    end

    def save(data)
      FileUtils.mkdir_p instances_root
      File.write(instances_root/"permissions.yml", YAML.dump(data.fetch(:all, {})))

      data.fetch(:instances, {}).each_pair do |name, role_users|
        FileUtils.mkdir_p instance_path(name).dirname
        File.write(instance_path(name), YAML.dump(role_users))
      end
    end

    private

    attr_reader :instances_root

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
