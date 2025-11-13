# frozen_string_literal: true

module SQA
  module TAI
    # Overlap Studies (Moving Averages, Bands)
    module OverlapStudies
      # Moving Average - Generic
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 30)
      # @param ma_type [Integer] MA type: 0=SMA, 1=EMA, 2=WMA, 3=DEMA, 4=TEMA, 5=TRIMA, 6=KAMA, 7=MAMA, 8=T3 (default: 0)
      # @return [Array<Float>] MA values
      def ma(prices, period: 30, ma_type: 0)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.ma(prices, time_period: period, ma_type: ma_type)
      end

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

      # Double Exponential Moving Average
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 30)
      # @return [Array<Float>] DEMA values
      def dema(prices, period: 30)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.dema(prices, time_period: period)
      end

      # Triple Exponential Moving Average
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 30)
      # @return [Array<Float>] TEMA values
      def tema(prices, period: 30)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.tema(prices, time_period: period)
      end

      # Triangular Moving Average
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 30)
      # @return [Array<Float>] TRIMA values
      def trima(prices, period: 30)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.trima(prices, time_period: period)
      end

      # Kaufman Adaptive Moving Average
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 30)
      # @return [Array<Float>] KAMA values
      def kama(prices, period: 30)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.kama(prices, time_period: period)
      end

      # Triple Exponential Moving Average (T3)
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 5)
      # @param vfactor [Float] Volume factor (default: 0.7)
      # @return [Array<Float>] T3 values
      def t3(prices, period: 5, vfactor: 0.7)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.t3(prices, time_period: period, vfactor: vfactor)
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

        result = TALibFFI.bbands(
          prices,
          time_period: period,
          nbdev_up: nbdev_up,
          nbdev_dn: nbdev_down
        )

        # Handle hash return format from newer ta_lib_ffi versions
        if result.is_a?(Hash)
          [result[:upper_band], result[:middle_band], result[:lower_band]]
        else
          result
        end
      end
    end
  end
end
