# frozen_string_literal: true

require "terminal-table"

module Moku
  # This class is specifcally for outputting a collection of
  # LoggedRelease, which it knows too much about. Its primary
  # purpose right now is to remove the need to test the functionality
  # in Releases
  class LoggedReleases
    def initialize(releases, shared_name: nil, unshared_name: nil)
      @releases = releases
      @shared_name = shared_name || Moku.shared_name
      @unshared_name = unshared_name || Moku.unshared_name
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
    attr_reader :shared_name, :unshared_name

    def short_rows # rubocop:disable Metrics/MethodLength
      releases.map(&:to_brief_hash).map do |hash|
        [
          hash[:id],
          hash[:user],
          hash[:version].sub("rollback ", "").slice(0, 11),
          hash[:source].slice(0, 7),
          hash[:deploy].slice(0, 7),
          hash[:unshared].slice(0, 7),
          hash[:shared].slice(0, 7)
        ]
      end
    end

    def rows # rubocop:disable Metrics/MethodLength
      releases.map(&:to_brief_hash).map do |hash|
        [
          hash[:id],
          hash[:user],
          hash[:version],
          hash[:source],
          hash[:deploy],
          hash[:unshared],
          hash[:shared]
        ]
      end
    end

    def headings
      [
        "id",
        "user",
        "version",
        "source",
        "deployed w/",
        unshared_name,
        shared_name
      ]
    end

  end
end
