# frozen_string_literal: true

module Fauxpaas

  # Runner that uses Kernel.system
  class KernelSystem
    def run(string)
      Kernel.system(string)
    end
  end
end
