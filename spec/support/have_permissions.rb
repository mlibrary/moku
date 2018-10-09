# frozen_string_literal: true

require "rspec/expectations"

RSpec::Matchers.define :have_permissions do |expected|
  description do
    "have file permissions #{expected}"
  end

  def mode(path)
    format("%o", path.stat.mode & 0o7777)
  rescue Errno::ENOENT
    "file does not exist"
  end

  match do |actual|
    mode(actual) == expected
  end

  failure_message do |actual|
    "expected permissions of #{expected} but got #{mode(actual)}"
  end
end
