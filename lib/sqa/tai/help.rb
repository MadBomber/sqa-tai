# frozen_string_literal: true

require "json"

module SQA
  module TAI
    # Help module containing documentation metadata and URLs
    module Help
      # Base URL for the documentation site
      BASE_URL = "https://madbomber.github.io/sqa-tai"

      class << self
        # Lazy-loaded indicator metadata
        # @return [Hash] Indicator metadata with symbolized keys
        def indicators
          @indicators ||= load_indicators
        end

        private

        def load_indicators
          read_indicators_json.transform_keys(&:to_sym).transform_values do |meta|
            symbolize_indicator_meta(meta)
          end
        end

        def read_indicators_json
          json_path = File.join(__dir__, "help", "data.json")
          JSON.parse(File.read(json_path))
        end

        # Convert a single indicator's metadata hash to symbol keys/values for Ruby idioms
        def symbolize_indicator_meta(meta)
          {
            name: meta["name"],
            category: meta["category"].to_sym,
            path: meta["path"]
          }
        end
      end
    end
  end
end

# Load help resource class
require_relative "help/resource"
