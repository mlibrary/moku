require "thor"
require "fauxpaas"

module Fauxpaas
  module CLI

    class Var < Thor
      desc "list <named_instance>", "List out the config"
      def list(named_instance)
        #TODO: authz
        Instance.new(named_instance).var_file
          .list
      end

      desc "add <named_instance> <key> <value>",
        "Add a variable on subsequent deploys"
      def add(named_instance, key, value)
        #TODO: authz
        Instance.new(named_instance).var_file
          .add(key, value)
      end

      desc "remove <named_instance> <key>",
        "Cease installing the key to value on subsequent deploys"
      def remove(named_instance, key)
        #TODO: authz
        Instance.new(named_instance).var_file
          .remove(key)
      end
    end

  end
end
