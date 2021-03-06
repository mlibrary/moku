# frozen_string_literal: true

require "pathname"
require "moku/scm/working_directory"

module Moku
  class SpoofedGitRunner
    def initialize(sytem = nil); end

    def branch
      "master"
    end

    def newbranch
      "newbranch"
    end

    def dumb_tag
      "some_tag"
    end

    def smart_tag
      "#{dumb_tag}^{}"
    end

    def short
      "5732244"
    end

    def long
      "5753224412a302aeedfdd73e7b04d914c298c169"
    end

    def long_for(commitish)
      @long_for ||= {
        branch    => long,
        newbranch => long,
        dumb_tag  => "66b689fbb3e5b689c3560d24dd50ac9027d94dbe",
        smart_tag => "f44af182ef3cae3d9c6946c18284658ac78008ac",
        short     => long,
        long      => long
      }
      @long_for[commitish]
    end

    def sha(_url, commitish)
      long_for(commitish)
    end

    def safe_checkout(_url, _commitish, _dir)
      wd = WorkingDirectory.new(tmpdir, [])
      if block_given?
        yield wd
      else
        wd
      end
    end

    def tmpdir
      Pathname.new("/some/tmp/dir")
    end

  end
end
