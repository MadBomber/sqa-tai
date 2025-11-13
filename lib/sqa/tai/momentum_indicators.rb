# frozen_string_literal: true

module SQA
  module TAI
    # Momentum Indicators
    module MomentumIndicators
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

        TALibFFI.imi(open_prices, close_prices, time_period: period)
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

        result = TALibFFI.macd(
          prices,
          fast_period: fast_period,
          slow_period: slow_period,
          signal_period: signal_period
        )

        # Handle hash return format from newer ta_lib_ffi versions
        if result.is_a?(Hash)
          [result[:macd], result[:macd_signal], result[:macd_hist]]
        else
          result
        end
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

        result = TALibFFI.stoch(
          high,
          low,
          close,
          fastk_period: fastk_period,
          slowk_period: slowk_period,
          slowd_period: slowd_period
        )

        # Handle hash return format from newer ta_lib_ffi versions
        if result.is_a?(Hash)
          [result[:slow_k], result[:slow_d]]
        else
          result
        end
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

        TALibFFI.cci(high, low, close, time_period: period)
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

        TALibFFI.willr(high, low, close, time_period: period)
      end

      # Rate of Change
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 10)
      # @return [Array<Float>] ROC values
      def roc(prices, period: 10)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.roc(prices, time_period: period)
      end

      # Rate of Change Percentage
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 10)
      # @return [Array<Float>] ROCP values
      def rocp(prices, period: 10)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.rocp(prices, time_period: period)
      end

      # Rate of Change Ratio
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 10)
      # @return [Array<Float>] ROCR values
      def rocr(prices, period: 10)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.rocr(prices, time_period: period)
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

        TALibFFI.ppo(prices, fast_period: fast_period, slow_period: slow_period, ma_type: ma_type)
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

        TALibFFI.adx(high, low, close, time_period: period)
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

        TALibFFI.adxr(high, low, close, time_period: period)
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

        TALibFFI.apo(prices, fast_period: fast_period, slow_period: slow_period, ma_type: ma_type)
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

        result = TALibFFI.aroon(high, low, time_period: period)

        # Handle hash return format from newer ta_lib_ffi versions
        if result.is_a?(Hash)
          [result[:aroon_down], result[:aroon_up]]
        else
          result
        end
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

        TALibFFI.aroonosc(high, low, time_period: period)
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

        TALibFFI.bop(open, high, low, close)
      end

      # Chande Momentum Oscillator
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] CMO values
      def cmo(prices, period: 14)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.cmo(prices, time_period: period)
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

        TALibFFI.dx(high, low, close, time_period: period)
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

        result = TALibFFI.macdext(
          prices,
          fast_period: fast_period,
          fast_ma_type: fast_ma_type,
          slow_period: slow_period,
          slow_ma_type: slow_ma_type,
          signal_period: signal_period,
          signal_ma_type: signal_ma_type
        )

        # Handle hash return format from newer ta_lib_ffi versions
        if result.is_a?(Hash)
          [result[:macd], result[:macd_signal], result[:macd_hist]]
        else
          result
        end
      end

      # MACD Fix 12/26
      # @param prices [Array<Float>] Array of prices
      # @param signal_period [Integer] Signal period (default: 9)
      # @return [Array<Array<Float>>] [macd, signal, histogram]
      def macdfix(prices, signal_period: 9)
        check_available!
        validate_prices!(prices)

        result = TALibFFI.macdfix(prices, signal_period: signal_period)

        # Handle hash return format from newer ta_lib_ffi versions
        if result.is_a?(Hash)
          [result[:macd], result[:macd_signal], result[:macd_hist]]
        else
          result
        end
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

        TALibFFI.mfi(high, low, close, volume, time_period: period)
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

        TALibFFI.minus_di(high, low, close, time_period: period)
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

        TALibFFI.minus_dm(high, low, time_period: period)
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

        TALibFFI.plus_di(high, low, close, time_period: period)
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

        TALibFFI.plus_dm(high, low, time_period: period)
      end

      # Rate of Change Ratio 100 scale
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 10)
      # @return [Array<Float>] ROCR100 values
      def rocr100(prices, period: 10)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.rocr100(prices, time_period: period)
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

        result = TALibFFI.stochf(
          high,
          low,
          close,
          fastk_period: fastk_period,
          fastd_period: fastd_period
        )

        # Handle hash return format from newer ta_lib_ffi versions
        if result.is_a?(Hash)
          [result[:fast_k], result[:fast_d]]
        else
          result
        end
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

        result = TALibFFI.stochrsi(
          prices,
          time_period: period,
          fastk_period: fastk_period,
          fastd_period: fastd_period
        )

        # Handle hash return format from newer ta_lib_ffi versions
        if result.is_a?(Hash)
          [result[:fast_k], result[:fast_d]]
        else
          result
        end
      end

      # 1-day Rate-Of-Change (ROC) of a Triple Smooth EMA
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 30)
      # @return [Array<Float>] TRIX values
      def trix(prices, period: 30)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.trix(prices, time_period: period)
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

        TALibFFI.ultosc(high, low, close, time_period1: period1, time_period2: period2, time_period3: period3)
      end
    end
  end
end
