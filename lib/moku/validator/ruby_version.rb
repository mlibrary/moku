# frozen_string_literal: true

require "moku/validator/validator"

module Moku
  module Validator

    # Validate an artifact's .ruby-version file. Specifically:
    # * There is a .ruby-version present
    # * It specifies only a major version (e.g. 2.5)
    class RubyVersion < Validator
      VERSION_FORM = /^[1-9]\.[0-9]+$/ # rubocop:disable Style/MutableConstant
      VERSION_MALFORMED = "A forbidden .ruby-version file was found. The .ruby-version" \
        " file must specify exactly MAJOR.MINOR version."
      VERSION_MISSING = "You must supply a .ruby-version file that specifies exactly" \
        " the MAJOR.MINOR version."

      def validate
        if path.exist?
          unless VERSION_FORM.match?(File.read(path))
            @errors << VERSION_MALFORMED
          end
        else
          @errors << VERSION_MISSING
        end
      end

      private

      alias_method :artifact, :target

      def path
        @path ||= artifact.path/".ruby-version"
      end
    end

  end
end
