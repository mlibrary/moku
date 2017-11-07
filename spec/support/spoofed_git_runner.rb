module Fauxpaas
  class SpoofedGitRunner
    def initialize(sytem = nil); end

    def branch; "master"; end
    def dumb_tag; "some_tag"; end
    def smart_tag; "#{dumb_tag}^{}"; end
    def short; "5732244"; end
    def long; "5753224412a302aeedfdd73e7b04d914c298c169"; end


    def long_for(commitish)
      @long_for ||= {
        branch => long,
        dumb_tag => "66b689fbb3e5b689c3560d24dd50ac9027d94dbe",
        smart_tag => "f44af182ef3cae3d9c6946c18284658ac78008ac",
        short => long,
        long => long
      }
      @long_for[commitish]
    end

    def sha(url, commitish)
      long_for(commitish)
    end

    def safe_checkout(url, commitish, &block)
      yield tmpdir
    end

    def tmpdir
      "/some/tmp/dir"
    end

  end
end
