# frozen_string_literal: true

module SQA
  module TAI
    # Momentum Indicators
    #
    # :reek:DataClump and :reek:LongParameterList -- these methods
    # intentionally mirror TA-Lib's own C function signatures (separate
    # high/low/close/period args, up to 7 for macdext); bundling them into
    # a value object would be a breaking public API change for this gem
    # and its downstream consumers (sqa, sqa-cli, sqa-advisor) and their
    # 133 published indicator doc pages.
    module MomentumIndicators
      # Relative Strength Index
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] RSI values
      def rsi(prices, period: 14)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        Native.rsi(prices, time_period: period)
      end

      # Intraday Momentum Index
      # @param open_prices [Array<Float>] Array of open prices
      # @param close_prices [Array<Float>] Array of close prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] IMI values
      def imi(open_prices, close_prices, period: 14)
        check_available!
        validate_prices!(open_prices)
        validate_prices!(close_prices)
        validate_period!(period, [open_prices.size, close_prices.size].min)

        Native.imi([open_prices, close_prices], time_period: period)
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

        Native.macd(prices, fast_period:, slow_period:, signal_period:).values_at(:macd, :macd_signal, :macd_hist)
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

        result = Native.stoch([high, low, close], fastk_period:, slowk_period:, slowd_period:)
        [result[:slow_k], result[:slow_d]]
      end

      # Momentum
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 10)
      # @return [Array<Float>] Momentum values
      def mom(prices, period: 10)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        Native.mom(prices, time_period: period)
      end

      # Commodity Channel Index
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] CCI values
      def cci(high, low, close, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cci([high, low, close], time_period: period)
      end

      # Williams' %R
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] WILLR values
      def willr(high, low, close, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.willr([high, low, close], time_period: period)
      end

      # Rate of Change
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 10)
      # @return [Array<Float>] ROC values
      def roc(prices, period: 10)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        Native.roc(prices, time_period: period)
      end

      # Rate of Change Percentage
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 10)
      # @return [Array<Float>] ROCP values
      def rocp(prices, period: 10)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        Native.rocp(prices, time_period: period)
      end

      # Rate of Change Ratio
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 10)
      # @return [Array<Float>] ROCR values
      def rocr(prices, period: 10)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        Native.rocr(prices, time_period: period)
      end

      # Percentage Price Oscillator
      # @param prices [Array<Float>] Array of prices
      # @param fast_period [Integer] Fast period (default: 12)
      # @param slow_period [Integer] Slow period (default: 26)
      # @param ma_type [Integer] Moving average type (default: 0)
      # @return [Array<Float>] PPO values
      def ppo(prices, fast_period: 12, slow_period: 26, ma_type: 0)
        check_available!
        validate_prices!(prices)

        Native.ppo(prices, fast_period:, slow_period:, ma_type:)
      end

      # Average Directional Movement Index
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] ADX values
      def adx(high, low, close, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.adx([high, low, close], time_period: period)
      end

      # Average Directional Movement Index Rating
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] ADXR values
      def adxr(high, low, close, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.adxr([high, low, close], time_period: period)
      end

      # Absolute Price Oscillator
      # @param prices [Array<Float>] Array of prices
      # @param fast_period [Integer] Fast period (default: 12)
      # @param slow_period [Integer] Slow period (default: 26)
      # @param ma_type [Integer] Moving average type (default: 0)
      # @return [Array<Float>] APO values
      def apo(prices, fast_period: 12, slow_period: 26, ma_type: 0)
        check_available!
        validate_prices!(prices)

        Native.apo(prices, fast_period:, slow_period:, ma_type:)
      end

      # Aroon
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Array<Float>>] [aroon_down, aroon_up]
      def aroon(high, low, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)

        result = Native.aroon([high, low], time_period: period)
        [result[:aroon_down], result[:aroon_up]]
      end

      # Aroon Oscillator
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] AROONOSC values
      def aroonosc(high, low, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)

        Native.aroonosc([high, low], time_period: period)
      end

      # Balance of Power
      # @param open [Array<Float>] Open prices
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @return [Array<Float>] BOP values
      def bop(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.bop([open, high, low, close])
      end

      # Chande Momentum Oscillator
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] CMO values
      def cmo(prices, period: 14)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        Native.cmo(prices, time_period: period)
      end

      # Directional Movement Index
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] DX values
      def dx(high, low, close, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.dx([high, low, close], time_period: period)
      end

      # MACD with Controllable MA Type
      # @param prices [Array<Float>] Array of prices
      # @param fast_period [Integer] Fast period (default: 12)
      # @param fast_ma_type [Integer] Fast MA type (default: 0)
      # @param slow_period [Integer] Slow period (default: 26)
      # @param slow_ma_type [Integer] Slow MA type (default: 0)
      # @param signal_period [Integer] Signal period (default: 9)
      # @param signal_ma_type [Integer] Signal MA type (default: 0)
      # @return [Array<Array<Float>>] [macd, signal, histogram]
      def macdext(prices, fast_period: 12, fast_ma_type: 0, slow_period: 26, slow_ma_type: 0, signal_period: 9, signal_ma_type: 0)
        check_available!
        validate_prices!(prices)

        Native.macdext(
          prices,
          fast_period:,
          fast_ma_type:,
          slow_period:,
          slow_ma_type:,
          signal_period:,
          signal_ma_type:
        ).values_at(:macd, :macd_signal, :macd_hist)
      end

      # MACD Fix 12/26
      # @param prices [Array<Float>] Array of prices
      # @param signal_period [Integer] Signal period (default: 9)
      # @return [Array<Array<Float>>] [macd, signal, histogram]
      def macdfix(prices, signal_period: 9)
        check_available!
        validate_prices!(prices)

        Native.macdfix(prices, signal_period:).values_at(:macd, :macd_signal, :macd_hist)
      end

      # Money Flow Index
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param volume [Array<Float>] Volume values
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] MFI values
      def mfi(high, low, close, volume, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)
        validate_prices!(volume)

        Native.mfi([high, low, close, volume], time_period: period)
      end

      # Minus Directional Indicator
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] MINUS_DI values
      def minus_di(high, low, close, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.minus_di([high, low, close], time_period: period)
      end

      # Minus Directional Movement
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] MINUS_DM values
      def minus_dm(high, low, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)

        Native.minus_dm([high, low], time_period: period)
      end

      # Plus Directional Indicator
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] PLUS_DI values
      def plus_di(high, low, close, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.plus_di([high, low, close], time_period: period)
      end

      # Plus Directional Movement
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] PLUS_DM values
      def plus_dm(high, low, period: 14)
        check_available!
        validate_prices!(high)
        validate_prices!(low)

        Native.plus_dm([high, low], time_period: period)
      end

      # Rate of Change Ratio 100 scale
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 10)
      # @return [Array<Float>] ROCR100 values
      # :reek:UncommunicativeMethodName -- ROCR100 is TA-Lib's own
      # canonical indicator name; renaming it breaks the public API.
      def rocr100(prices, period: 10)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        Native.rocr100(prices, time_period: period)
      end

      # Stochastic Fast
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param fastk_period [Integer] Fast K period (default: 5)
      # @param fastd_period [Integer] Fast D period (default: 3)
      # @return [Array<Array<Float>>] [fastk, fastd]
      def stochf(high, low, close, fastk_period: 5, fastd_period: 3)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        result = Native.stochf([high, low, close], fastk_period:, fastd_period:)
        [result[:fast_k], result[:fast_d]]
      end

      # Stochastic RSI
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 14)
      # @param fastk_period [Integer] Fast K period (default: 5)
      # @param fastd_period [Integer] Fast D period (default: 3)
      # @return [Array<Array<Float>>] [fastk, fastd]
      def stochrsi(prices, period: 14, fastk_period: 5, fastd_period: 3)
        check_available!
        validate_prices!(prices)

        result = Native.stochrsi(prices, time_period: period, fastk_period:, fastd_period:)
        [result[:fast_k], result[:fast_d]]
      end

      # 1-day Rate-Of-Change (ROC) of a Triple Smooth EMA
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 30)
      # @return [Array<Float>] TRIX values
      def trix(prices, period: 30)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        Native.trix(prices, time_period: period)
      end

      # Ultimate Oscillator
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param period1 [Integer] First period (default: 7)
      # @param period2 [Integer] Second period (default: 14)
      # @param period3 [Integer] Third period (default: 28)
      # @return [Array<Float>] ULTOSC values
      def ultosc(high, low, close, period1: 7, period2: 14, period3: 28)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.ultosc([high, low, close], time_period1: period1, time_period2: period2, time_period3: period3)
      end
    end
  end
end
