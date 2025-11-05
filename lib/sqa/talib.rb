# frozen_string_literal: true

require_relative "talib/version"
require "ta_lib_ffi"

module SQA
  module TALib
    class Error < StandardError; end
    class TALibNotInstalledError < Error; end
    class InvalidParameterError < Error; end

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

        raise TALibNotInstalledError,
              "TA-Lib C library is not installed. " \
              "Please install it from https://ta-lib.org/"
      end

      # ========================================
      # Overlap Studies (Moving Averages, Bands)
      # ========================================

      # Simple Moving Average
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 30)
      # @return [Array<Float>] SMA values
      def sma(prices, period: 30)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.sma(prices, time_period: period)
      end

      # Exponential Moving Average
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 30)
      # @return [Array<Float>] EMA values
      def ema(prices, period: 30)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.ema(prices, time_period: period)
      end

      # Weighted Moving Average
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 30)
      # @return [Array<Float>] WMA values
      def wma(prices, period: 30)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.wma(prices, time_period: period)
      end

      # Bollinger Bands
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 5)
      # @param nbdev_up [Float] Upper deviation (default: 2.0)
      # @param nbdev_down [Float] Lower deviation (default: 2.0)
      # @return [Array<Array<Float>>] [upper_band, middle_band, lower_band]
      def bbands(prices, period: 5, nbdev_up: 2.0, nbdev_down: 2.0)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.bbands(
          prices,
          time_period: period,
          nbdev_up: nbdev_up,
          nbdev_dn: nbdev_down
        )
      end

      # ========================================
      # Momentum Indicators
      # ========================================

      # Relative Strength Index
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] RSI values
      def rsi(prices, period: 14)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.rsi(prices, time_period: period)
      end

      # Moving Average Convergence/Divergence
      # @param prices [Array<Float>] Array of prices
      # @param fast_period [Integer] Fast period (default: 12)
      # @param slow_period [Integer] Slow period (default: 26)
      # @param signal_period [Integer] Signal period (default: 9)
      # @return [Array<Array<Float>>] [macd, signal, histogram]
      def macd(prices, fast_period: 12, slow_period: 26, signal_period: 9)
        check_available!
        validate_prices!(prices)

        TALibFFI.macd(
          prices,
          fast_period: fast_period,
          slow_period: slow_period,
          signal_period: signal_period
        )
      end

      # Stochastic Oscillator
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param fastk_period [Integer] Fast K period (default: 5)
      # @param slowk_period [Integer] Slow K period (default: 3)
      # @param slowd_period [Integer] Slow D period (default: 3)
      # @return [Array<Array<Float>>] [slowk, slowd]
      def stoch(high, low, close, fastk_period: 5, slowk_period: 3, slowd_period: 3)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.stoch(
          high,
          low,
          close,
          fastk_period: fastk_period,
          slowk_period: slowk_period,
          slowd_period: slowd_period
        )
      end

      # Momentum
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 10)
      # @return [Array<Float>] Momentum values
      def mom(prices, period: 10)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.mom(prices, time_period: period)
      end

      # ========================================
      # Volatility Indicators
      # ========================================

      # Average True Range
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] ATR values
      def atr(high, low, close, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.atr(high, low, close, time_period: period)
      end

      # True Range
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @return [Array<Float>] True Range values
      def trange(high, low, close)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.trange(high, low, close)
      end

      # ========================================
      # Volume Indicators
      # ========================================

      # On Balance Volume
      # @param close [Array<Float>] Close prices
      # @param volume [Array<Float>] Volume values
      # @return [Array<Float>] OBV values
      def obv(close, volume)
        check_available!
        validate_prices!(close)
        validate_prices!(volume)

        TALibFFI.obv(close, volume)
      end

      # Chaikin A/D Line
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param volume [Array<Float>] Volume values
      # @return [Array<Float>] AD values
      def ad(high, low, close, volume)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)
        validate_prices!(volume)

        TALibFFI.ad(high, low, close, volume)
      end

      # ========================================
      # Pattern Recognition
      # ========================================

      # Doji candlestick pattern
      # @param open [Array<Float>] Open prices
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @return [Array<Integer>] Pattern signals (-100 to 100)
      def cdl_doji(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdldoji(open, high, low, close)
      end

      # Hammer candlestick pattern
      def cdl_hammer(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlhammer(open, high, low, close)
      end

      # Engulfing pattern
      def cdl_engulfing(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlengulfing(open, high, low, close)
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
