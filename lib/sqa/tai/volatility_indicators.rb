# frozen_string_literal: true

module SQA
  module TAI
    # Volatility Indicators
    #
    # :reek:DataClump and :reek:LongParameterList -- these methods
    # intentionally mirror TA-Lib's own C function signatures (separate
    # high/low/close/period args, up to 7 for sarext); bundling them into
    # a value object would be a breaking public API change for this gem
    # and its downstream consumers (sqa, sqa-cli, sqa-advisor) and their
    # 133 published indicator doc pages.
    module VolatilityIndicators
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

        Native.atr([high, low, close], time_period: period)
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

        Native.trange([high, low, close])
      end

      # Normalized Average True Range
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] NATR values
      def natr(high, low, close, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.natr([high, low, close], time_period: period)
      end

      # Parabolic SAR
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param acceleration [Float] Acceleration factor (default: 0.02)
      # @param maximum [Float] Maximum acceleration (default: 0.20)
      # @return [Array<Float>] SAR values
      def sar(high, low, acceleration: 0.02, maximum: 0.20)
        check_available!
        validate_prices!(high)
        validate_prices!(low)

        Native.sar([high, low], acceleration:, maximum:)
      end

      # Parabolic SAR - Extended
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param start_value [Float] Start value (default: 0.0)
      # @param offset_on_reverse [Float] Offset on reverse (default: 0.0)
      # @param acceleration_init [Float] Acceleration init (default: 0.02)
      # @param acceleration_step [Float] Acceleration step (default: 0.02)
      # @param acceleration_max [Float] Acceleration max (default: 0.20)
      # @return [Array<Float>] SAREXT values
      def sarext(high, low, start_value: 0.0, offset_on_reverse: 0.0, acceleration_init: 0.02, acceleration_step: 0.02,
                 acceleration_max: 0.20)
        check_available!
        validate_prices!(high)
        validate_prices!(low)

        Native.sarext([high, low],
                      start_value:,
                      offset_on_reverse:,
                      af_init: acceleration_init,
                      af_increment: acceleration_step,
                      af_max: acceleration_max)
      end

      # Acceleration Bands
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param period [Integer] Time period (default: 20)
      # @return [Array<Array<Float>>] [upper_band, middle_band, lower_band]
      def accbands(high, low, close, period: 20)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)
        validate_period!(period, [high.size, low.size, close.size].min)

        result = Native.accbands([high, low, close], time_period: period)
        [result[:upper_band], result[:middle_band], result[:lower_band]]
      end

      # Hilbert Transform - Instantaneous Trendline
      # @param prices [Array<Float>] Array of prices
      # @return [Array<Float>] Trendline values
      def ht_trendline(prices)
        check_available!
        validate_prices!(prices)

        Native.ht_trendline(prices)
      end

      # MESA Adaptive Moving Average
      # @param prices [Array<Float>] Array of prices
      # @param fast_limit [Float] Fast limit (default: 0.5)
      # @param slow_limit [Float] Slow limit (default: 0.05)
      # @return [Array<Array<Float>>] [mama, fama]
      def mama(prices, fast_limit: 0.5, slow_limit: 0.05)
        check_available!
        validate_prices!(prices)

        result = Native.mama(prices, fastlimit: fast_limit, slowlimit: slow_limit)
        [result[:mama], result[:fama]]
      end

      # Moving Average with Variable Period
      # @param prices [Array<Float>] Array of prices
      # @param periods [Array<Integer>] Array of periods for each data point
      # @param ma_type [Integer] Moving average type (default: 0)
      # @return [Array<Float>] MAVP values
      def mavp(prices, periods, ma_type: 0)
        check_available!
        validate_prices!(prices)
        validate_prices!(periods)

        Native.mavp(prices, periods, ma_type:)
      end

      # Midpoint over period
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] Midpoint values
      def midpoint(prices, period: 14)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        Native.midpoint(prices, time_period: period)
      end

      # Midpoint Price over period
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] Midpoint price values
      def midprice(high, low, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_period!(period, [high.size, low.size].min)

        Native.midprice([high, low], time_period: period)
      end
    end
  end
end
