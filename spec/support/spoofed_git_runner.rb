module Fauxpaas
  class SpoofedGitRunner
    def initialize(sytem = nil); end

    BRANCH =    "master"
    DUMB_TAG =  "some_tag"
    SMART_TAG = "#{DUMB_TAG}^{}"
    SHORT =     "5732244"
    LONG =      "5753224412a302aeedfdd73e7b04d914c298c169"

    def branch; BRANCH; end
    def dumb_tag; DUMB_TAG; end
    def smart_tag; SMART_TAG; end
    def short; SHORT; end
    def long; LONG; end

    def resolved_remote(commitish)
      @resolved_remote ||= {
        BRANCH => "5753224412a302aeedfdd73e7b04d914c298c169",
        DUMB_TAG => "66b689fbb3e5b689c3560d24dd50ac9027d94dbe",
        SMART_TAG => "f44af182ef3cae3d9c6946c18284658ac78008ac",
        SHORT => SHORT,
        LONG => LONG
      }
      @resolved_remote[commitish]
    end

    def ls_remote(url, commitish)
      @ls_remote ||= {
        BRANCH => [
          ["5753224412a302aeedfdd73e7b04d914c298c169",  "HEAD"],
          ["5753224412a302aeedfdd73e7b04d914c298c169",  "refs/heads/develop"],
          ["66b689fbb3e5b689c3560d24dd50ac9027d94dbe",  "refs/heads/feature/aeid-94-restart"],
          ["34cfe233054f3353b4576d3a29ede56c09d32658",  "refs/heads/fixup/config"],
          ["022702e093cc0071f88e66ca54ae8886397cc11a",  "refs/heads/fixup/deploy_releases"],
          ["1128b45d32156fb49d9f15359ebe38e3dd5e3ac1",  "refs/heads/master"],
          ["ad6b82c09e26b7f09d1512596cc32d0dad3d9bc2",  "refs/pull/1/head"],
          ["5777acb0c7f3bf5a4c30731904c11dcd7045f3cf",  "refs/pull/10/head"],
          ["f44af182ef3cae3d9c6946c18284658ac78008ac",  "refs/pull/11/head"]
        ],
        DUMB_TAG => [["66b689fbb3e5b689c3560d24dd50ac9027d94dbe",  "refs/heads/feature/aeid-94-restart"]],
        SMART_TAG => [["f44af182ef3cae3d9c6946c18284658ac78008ac",  "refs/pull/11/head"]],
        SHORT => [],
        LONG => []
      }
      @ls_remote[commitish]
    end

    def resolved_local(commitish)
      rev_parse(commitish)
    end

    def rev_parse(commitish)
      @rev_parse ||= {
        BRANCH => "5753224412a302aeedfdd73e7b04d914c298c169",
        DUMB_TAG => "66b689fbb3e5b689c3560d24dd50ac9027d94dbe",
        SMART_TAG => "f44af182ef3cae3d9c6946c18284658ac78008ac",
        SHORT => LONG,
        LONG => LONG
      }
      @rev_parse[commitish]
    end

    def safe_checkout(url, commitish, &block)
      yield tmpdir
    end

    def tmpdir
      "/some/tmp/dir"
    end

  end
end
