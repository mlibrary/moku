# frozen_string_literal: true

require "moku/status"
require "ostruct"

module Moku

  # A utility for processing sequences of callables that return Moku::Status
  # objects.
  class Sequence

    # Call (via the #call method) each item, passing the given args, until
    # either the collection is exhausted or one of the items returns a failing
    # Status object. If no failures are encountered, this returns a successful
    # Status object. Otherwise, it returns the failed status object.
    def self.do(items, *args)
      items.reduce(Status.success) do |last_result, item|
        break(last_result) unless last_result.success?

        item.call(*args)
      end
    end

    # Execute the block for each item, passing the item to the block, until
    # either the collection is exhausted or one of the items returns a failing
    # Status object. If no failures are encountered, this returns a successful
    # Status object. Otherwise, it returns a failed status object.
    def self.for(items)
      items.reduce(OpenStruct.new(success?: true)) do |last_result, item|
        break(last_result) unless last_result.success?

        yield item
      end
    end

  end
end
