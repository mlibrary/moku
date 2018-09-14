# frozen_string_literal: true

require "terminal-table"

module Fauxpaas
  # This class is specifcally for outputting a collection of
  # LoggedRelease, which it knows too much about. Its primary
  # purpose right now is to remove the need to test the functionality
  # in Releases
  class LoggedReleases
    def initialize(releases)
      @releases = releases
    end

    def to_s
      Terminal::Table.new do |t|
        t.headings = headings
        t.rows = rows
        t.style = {
          all_separators: false,
          border_bottom: false,
          border_top: false
        }
      end.to_s
    end

    def to_short_s
      Terminal::Table.new do |t|
        t.headings = headings
        t.rows = short_rows
        t.style = {
          all_separators: false,
          border_bottom: false,
          border_top: false
        }
      end.to_s
    end

    private

    attr_reader :releases

    def short_rows
      releases.map(&:to_brief_hash).map do |hash|
        [
          hash[:time],
          hash[:user],
          hash[:source].slice(0, 7),
          hash[:deploy].slice(0, 7),
          hash[:unshared].slice(0, 7),
          hash[:shared].slice(0, 7)
        ]
      end
    end

    def rows
      releases.map(&:to_brief_hash).map do |hash|
        [
          hash[:time],
          hash[:user],
          hash[:source],
          hash[:deploy],
          hash[:unshared],
          hash[:shared]
        ]
      end
    end

    def headings
      [
        "timestamp",
        "user",
        "source",
        "deployed w/",
        Fauxpaas.unshared_name,
        Fauxpaas.shared_name
      ]
    end

  end
end
