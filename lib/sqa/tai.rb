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
