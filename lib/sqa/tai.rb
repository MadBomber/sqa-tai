# frozen_string_literal: true

require_relative "tai/version"
require "ta_lib_ffi"

# Apply monkey patch to fix ta_lib_ffi 0.3.0 multi-array parameter bug
require_relative "../extensions/ta_lib_ffi"

# Require all indicator modules
require_relative "tai/overlap_studies"
require_relative "tai/momentum_indicators"
require_relative "tai/volatility_indicators"
require_relative "tai/volume_indicators"
require_relative "tai/price_transform"
require_relative "tai/cycle_indicators"
require_relative "tai/statistical_functions"
require_relative "tai/pattern_recognition"

# Require help system
require_relative "tai/help"

module SQA
  module TAI
    class Error < StandardError; end
    class TAINotInstalledError < Error; end
    class InvalidParameterError < Error; end

    # Include all indicator modules
    extend OverlapStudies
    extend MomentumIndicators
    extend VolatilityIndicators
    extend VolumeIndicators
    extend PriceTransform
    extend CycleIndicators
    extend StatisticalFunctions
    extend PatternRecognition

    class << self
      # Check if TA-Lib C library is available
      def available?
        defined?(TALibFFI) && TALibFFI.respond_to?(:sma)
      rescue LoadError
        false
      end

      # Verify TA-Lib is available, raise error if not
      def check_available!
        return if available?

        raise TAINotInstalledError,
              "TA-Lib C library is not installed. " \
              "Please install it from https://ta-lib.org/"
      end

      # Get help documentation for indicators
      #
      # @param indicator [Symbol, nil] The indicator to get help for
      # @param options [Hash] Options for help output
      # @option options [Symbol] :category Filter by category
      # @option options [String] :search Search for indicators
      # @option options [Boolean] :open Open URL in browser
      # @option options [Symbol] :format Return format (:uri, :hash, or Help::Resource)
      #
      # @return [Help::Resource, Hash, String, URI] Help information
      #
      # @example Get help for SMA
      #   SQA::TAI.help(:sma)
      #   # => #<SQA::TAI::Help::Resource ...>
      #
      # @example Open help in browser
      #   SQA::TAI.help(:rsi, open: true)
      #
      # @example List all momentum indicators
      #   SQA::TAI.help(category: :momentum_indicators)
      #
      # @example Search for indicators
      #   SQA::TAI.help(search: "moving average")
      #
      def help(indicator = nil, **options)
        # List all indicators
        if indicator == :all
          return Help.indicators.transform_values { |meta| "#{Help::BASE_URL}/#{meta[:path]}/" }
        end

        # Category listing
        if options[:category]
          category_indicators = Help.indicators.select { |_k, v| v[:category] == options[:category] }
          return category_indicators.transform_values { |meta| "#{Help::BASE_URL}/#{meta[:path]}/" }
        end

        # Search
        if options[:search]
          query = options[:search].downcase
          matches = Help.indicators.select do |k, v|
            k.to_s.include?(query) || v[:name].downcase.include?(query)
          end
          return matches.transform_values { |meta| "#{Help::BASE_URL}/#{meta[:path]}/" }
        end

        # Single indicator
        meta = Help.indicators[indicator]
        raise ArgumentError, "Unknown indicator: #{indicator}" unless meta

        resource = Help::Resource.new(indicator, meta[:name], meta[:category], meta[:path])

        # Open in browser if requested
        resource.open if options[:open]

        # Return format
        case options[:format]
        when :uri then resource.uri
        when :hash then {name: meta[:name], category: meta[:category], url: resource.url}
        else resource # Return Help::Resource object (responds to to_s)
        end
      end

      private

      def validate_prices!(prices)
        raise InvalidParameterError, "Prices array cannot be nil" if prices.nil?
        raise InvalidParameterError, "Prices array cannot be empty" if prices.empty?
        raise InvalidParameterError, "Prices must be an array" unless prices.is_a?(Array)
      end

      def validate_period!(period, data_size)
        raise InvalidParameterError, "Period must be positive" if period <= 0
        raise InvalidParameterError, "Period (#{period}) cannot exceed data size (#{data_size})" if period > data_size
      end
    end
  end
end
