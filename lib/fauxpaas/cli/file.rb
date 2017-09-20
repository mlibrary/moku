require "thor"
require "fauxpaas"

module Fauxpaas
  module CLI

    class File < Thor
      desc "list <named_instance>", "List the files"
      def list(named_instance)
        #TODO: authz
        #TODO: add SHA to params or option
        History.new(Instance.new(named_instance)).checkout(sha) do |instance|
          instance.config_files.list
        end
      end

      desc "show <named_instance> <filename>", "Show the contents of a file"
      def show(named_instance, app_path)
        #TODO: authz
        #TODO: add SHA to params or option
        History.new(Instance.new(named_instance)).checkout(sha) do |instance|
          instance.config_files.read(app_path)
        end
      end

      desc "add <named_instance> <app_path>",
        "Add a file to be installed to <app_path> on subsequent deploys"
      def add(named_instance, filename, app_path)
        #TODO: authz
        contents = STDIN.gets
        Instance.new(named_instance).config_files
          .add(filename, app_path, contents)
      end

      desc "remove <named_instance> <app_path>",
        "Cease installing the file to <app_path> on subsequent deploys"
      def remove(named_instance, app_path)
        #TODO: authz
        Instance.new(named_instance).config_files
          .remove(app_path)
      end

      desc "move <named_instance> <app_path> <new_app_path>",
        "Install the file at <app_path> to <new_app_path> instead on subsequent deploys"
      def move(named_instance, app_path, new_app_path)
        #TODO: authz
        Instance.new(named_instance).config_files
          .move(app_path, new_app_path)
      end
    end

  end
end
