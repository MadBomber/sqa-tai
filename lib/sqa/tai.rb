# frozen_string_literal: true

require_relative "tai/version"
require "ta_lib_ffi"

# Apply monkey patch to fix ta_lib_ffi 0.3.0 multi-array parameter bug
require_relative "../extensions/ta_lib_ffi"

module SQA
  module TAI
    class Error < StandardError; end
    class TAINotInstalledError < Error; end
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

        raise TAINotInstalledError,
              "TA-Lib C library is not installed. " \
              "Please install it from https://ta-lib.org/"
      end

      # ========================================
      # Overlap Studies (Moving Averages, Bands)
      # ========================================

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

        TALibFFI.natr(high, low, close, time_period: period)
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

        TALibFFI.sar(high, low, acceleration: acceleration, maximum: maximum)
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
      def sarext(high, low, start_value: 0.0, offset_on_reverse: 0.0, acceleration_init: 0.02, acceleration_step: 0.02, acceleration_max: 0.20)
        check_available!
        validate_prices!(high)
        validate_prices!(low)

        TALibFFI.sarext(high, low,
          start_value: start_value,
          offset_on_reverse: offset_on_reverse,
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

        result = TALibFFI.accbands(high, low, close, time_period: period)

        # Handle hash return format from newer ta_lib_ffi versions
        if result.is_a?(Hash)
          [result[:upper_band], result[:middle_band], result[:lower_band]]
        else
          result
        end
      end

      # Hilbert Transform - Instantaneous Trendline
      # @param prices [Array<Float>] Array of prices
      # @return [Array<Float>] Trendline values
      def ht_trendline(prices)
        check_available!
        validate_prices!(prices)

        TALibFFI.ht_trendline(prices)
      end

      # MESA Adaptive Moving Average
      # @param prices [Array<Float>] Array of prices
      # @param fast_limit [Float] Fast limit (default: 0.5)
      # @param slow_limit [Float] Slow limit (default: 0.05)
      # @return [Array<Array<Float>>] [mama, fama]
      def mama(prices, fast_limit: 0.5, slow_limit: 0.05)
        check_available!
        validate_prices!(prices)

        result = TALibFFI.mama(prices, fastlimit: fast_limit, slowlimit: slow_limit)

        # Handle hash return format from newer ta_lib_ffi versions
        if result.is_a?(Hash)
          [result[:mama], result[:fama]]
        else
          result
        end
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

        TALibFFI.mavp(prices, periods, ma_type: ma_type)
      end

      # Midpoint over period
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] Midpoint values
      def midpoint(prices, period: 14)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.midpoint(prices, time_period: period)
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

        TALibFFI.midprice(high, low, time_period: period)
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

      # Chaikin A/D Oscillator
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param volume [Array<Float>] Volume values
      # @param fast_period [Integer] Fast period (default: 3)
      # @param slow_period [Integer] Slow period (default: 10)
      # @return [Array<Float>] ADOSC values
      def adosc(high, low, close, volume, fast_period: 3, slow_period: 10)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)
        validate_prices!(volume)

        TALibFFI.adosc(high, low, close, volume, fast_period: fast_period, slow_period: slow_period)
      end

      # ========================================
      # Price Transform
      # ========================================

      # Average Price
      # @param open [Array<Float>] Open prices
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @return [Array<Float>] Average price values
      def avgprice(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.avgprice(open, high, low, close)
      end

      # Median Price
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @return [Array<Float>] Median price values
      def medprice(high, low)
        check_available!
        validate_prices!(high)
        validate_prices!(low)

        TALibFFI.medprice(high, low)
      end

      # Typical Price
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @return [Array<Float>] Typical price values
      def typprice(high, low, close)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.typprice(high, low, close)
      end

      # Weighted Close Price
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @return [Array<Float>] Weighted close price values
      def wclprice(high, low, close)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.wclprice(high, low, close)
      end

      # ========================================
      # Cycle Indicators
      # ========================================

      # Hilbert Transform - Dominant Cycle Period
      # @param prices [Array<Float>] Array of prices
      # @return [Array<Float>] Dominant cycle period values
      def ht_dcperiod(prices)
        check_available!
        validate_prices!(prices)

        TALibFFI.ht_dcperiod(prices)
      end

      # Hilbert Transform - Trend vs Cycle Mode
      # @param prices [Array<Float>] Array of prices
      # @return [Array<Integer>] Trend mode (1) or cycle mode (0)
      def ht_trendmode(prices)
        check_available!
        validate_prices!(prices)

        TALibFFI.ht_trendmode(prices)
      end

      # Hilbert Transform - Dominant Cycle Phase
      # @param prices [Array<Float>] Array of prices
      # @return [Array<Float>] Dominant cycle phase values
      def ht_dcphase(prices)
        check_available!
        validate_prices!(prices)

        TALibFFI.ht_dcphase(prices)
      end

      # Hilbert Transform - Phasor Components
      # @param prices [Array<Float>] Array of prices
      # @return [Array<Array<Float>>] [inphase, quadrature]
      def ht_phasor(prices)
        check_available!
        validate_prices!(prices)

        result = TALibFFI.ht_phasor(prices)

        # Handle hash return format from newer ta_lib_ffi versions
        if result.is_a?(Hash)
          [result[:in_phase], result[:quadrature]]
        else
          result
        end
      end

      # Hilbert Transform - SineWave
      # @param prices [Array<Float>] Array of prices
      # @return [Array<Array<Float>>] [sine, lead_sine]
      def ht_sine(prices)
        check_available!
        validate_prices!(prices)

        result = TALibFFI.ht_sine(prices)

        # Handle hash return format from newer ta_lib_ffi versions
        if result.is_a?(Hash)
          [result[:sine], result[:lead_sine]]
        else
          result
        end
      end

      # ========================================
      # Statistical Functions
      # ========================================

      # Pearson's Correlation Coefficient
      # @param prices1 [Array<Float>] First array of prices
      # @param prices2 [Array<Float>] Second array of prices
      # @param period [Integer] Time period (default: 30)
      # @return [Array<Float>] Correlation values
      def correl(prices1, prices2, period: 30)
        check_available!
        validate_prices!(prices1)
        validate_prices!(prices2)
        validate_period!(period, [prices1.size, prices2.size].min)

        TALibFFI.correl(prices1, prices2, time_period: period)
      end

      # Beta
      # @param prices1 [Array<Float>] First array of prices
      # @param prices2 [Array<Float>] Second array of prices
      # @param period [Integer] Time period (default: 5)
      # @return [Array<Float>] Beta values
      def beta(prices1, prices2, period: 5)
        check_available!
        validate_prices!(prices1)
        validate_prices!(prices2)
        validate_period!(period, [prices1.size, prices2.size].min)

        TALibFFI.beta(prices1, prices2, time_period: period)
      end

      # Variance
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 5)
      # @param nbdev [Float] Number of deviations (default: 1.0)
      # @return [Array<Float>] Variance values
      def var(prices, period: 5, nbdev: 1.0)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.var(prices, time_period: period, nbdev: nbdev)
      end

      # Standard Deviation
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 5)
      # @param nbdev [Float] Number of deviations (default: 1.0)
      # @return [Array<Float>] Standard deviation values
      def stddev(prices, period: 5, nbdev: 1.0)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.stddev(prices, time_period: period, nbdev: nbdev)
      end

      # Linear Regression
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] Linear regression values
      def linearreg(prices, period: 14)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.linearreg(prices, time_period: period)
      end

      # Linear Regression Angle
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] Linear regression angle values
      def linearreg_angle(prices, period: 14)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.linearreg_angle(prices, time_period: period)
      end

      # Linear Regression Intercept
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] Linear regression intercept values
      def linearreg_intercept(prices, period: 14)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.linearreg_intercept(prices, time_period: period)
      end

      # Linear Regression Slope
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] Linear regression slope values
      def linearreg_slope(prices, period: 14)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.linearreg_slope(prices, time_period: period)
      end

      # Time Series Forecast
      # @param prices [Array<Float>] Array of prices
      # @param period [Integer] Time period (default: 14)
      # @return [Array<Float>] Time series forecast values
      def tsf(prices, period: 14)
        check_available!
        validate_prices!(prices)
        validate_period!(period, prices.size)

        TALibFFI.tsf(prices, time_period: period)
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

      # Morning Star pattern
      def cdl_morningstar(open, high, low, close, penetration: 0.3)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlmorningstar(open, high, low, close, penetration: penetration)
      end

      # Evening Star pattern
      def cdl_eveningstar(open, high, low, close, penetration: 0.3)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdleveningstar(open, high, low, close, penetration: penetration)
      end

      # Harami pattern
      def cdl_harami(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlharami(open, high, low, close)
      end

      # Piercing pattern
      def cdl_piercing(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlpiercing(open, high, low, close)
      end

      # Shooting Star pattern
      def cdl_shootingstar(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlshootingstar(open, high, low, close)
      end

      # Marubozu pattern
      def cdl_marubozu(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlmarubozu(open, high, low, close)
      end

      # Spinning Top pattern
      def cdl_spinningtop(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlspinningtop(open, high, low, close)
      end

      # Dragonfly Doji pattern
      def cdl_dragonflydoji(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdldragonflydoji(open, high, low, close)
      end

      # Gravestone Doji pattern
      def cdl_gravestonedoji(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlgravestonedoji(open, high, low, close)
      end

      # Two Crows pattern
      def cdl_2crows(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdl2crows(open, high, low, close)
      end

      # Three Black Crows pattern
      def cdl_3blackcrows(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdl3blackcrows(open, high, low, close)
      end

      # Three Inside Up/Down pattern
      def cdl_3inside(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdl3inside(open, high, low, close)
      end

      # Three Line Strike pattern
      def cdl_3linestrike(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdl3linestrike(open, high, low, close)
      end

      # Three Outside Up/Down pattern
      def cdl_3outside(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdl3outside(open, high, low, close)
      end

      # Three Stars In The South pattern
      def cdl_3starsinsouth(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdl3starsinsouth(open, high, low, close)
      end

      # Three Advancing White Soldiers pattern
      def cdl_3whitesoldiers(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdl3whitesoldiers(open, high, low, close)
      end

      # Abandoned Baby pattern
      def cdl_abandonedbaby(open, high, low, close, penetration: 0.3)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlabandonedbaby(open, high, low, close, penetration: penetration)
      end

      # Advance Block pattern
      def cdl_advanceblock(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdladvanceblock(open, high, low, close)
      end

      # Belt-hold pattern
      def cdl_belthold(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlbelthold(open, high, low, close)
      end

      # Breakaway pattern
      def cdl_breakaway(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlbreakaway(open, high, low, close)
      end

      # Closing Marubozu pattern
      def cdl_closingmarubozu(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlclosingmarubozu(open, high, low, close)
      end

      # Concealing Baby Swallow pattern
      def cdl_concealbabyswall(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlconcealbabyswall(open, high, low, close)
      end

      # Counterattack pattern
      def cdl_counterattack(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlcounterattack(open, high, low, close)
      end

      # Dark Cloud Cover pattern
      def cdl_darkcloudcover(open, high, low, close, penetration: 0.5)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdldarkcloudcover(open, high, low, close, penetration: penetration)
      end

      # Doji Star pattern
      def cdl_dojistar(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdldojistar(open, high, low, close)
      end

      # Evening Doji Star pattern
      def cdl_eveningdojistar(open, high, low, close, penetration: 0.3)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdleveningdojistar(open, high, low, close, penetration: penetration)
      end

      # Up/Down-gap side-by-side white lines pattern
      def cdl_gapsidesidewhite(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlgapsidesidewhite(open, high, low, close)
      end

      # Hanging Man pattern
      def cdl_hangingman(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlhangingman(open, high, low, close)
      end

      # Harami Cross pattern
      def cdl_haramicross(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlharamicross(open, high, low, close)
      end

      # High-Wave Candle pattern
      def cdl_highwave(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlhighwave(open, high, low, close)
      end

      # Hikkake pattern
      def cdl_hikkake(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlhikkake(open, high, low, close)
      end

      # Modified Hikkake pattern
      def cdl_hikkakemod(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlhikkakemod(open, high, low, close)
      end

      # Homing Pigeon pattern
      def cdl_homingpigeon(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlhomingpigeon(open, high, low, close)
      end

      # Identical Three Crows pattern
      def cdl_identical3crows(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlidentical3crows(open, high, low, close)
      end

      # In-Neck pattern
      def cdl_inneck(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlinneck(open, high, low, close)
      end

      # Inverted Hammer pattern
      def cdl_invertedhammer(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlinvertedhammer(open, high, low, close)
      end

      # Kicking pattern
      def cdl_kicking(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlkicking(open, high, low, close)
      end

      # Kicking - bull/bear determined by the longer marubozu
      def cdl_kickingbylength(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlkickingbylength(open, high, low, close)
      end

      # Ladder Bottom pattern
      def cdl_ladderbottom(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlladderbottom(open, high, low, close)
      end

      # Long Legged Doji pattern
      def cdl_longleggeddoji(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdllongleggeddoji(open, high, low, close)
      end

      # Long Line Candle pattern
      def cdl_longline(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdllongline(open, high, low, close)
      end

      # Matching Low pattern
      def cdl_matchinglow(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlmatchinglow(open, high, low, close)
      end

      # Mat Hold pattern
      def cdl_mathold(open, high, low, close, penetration: 0.5)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlmathold(open, high, low, close, penetration: penetration)
      end

      # Morning Doji Star pattern
      def cdl_morningdojistar(open, high, low, close, penetration: 0.3)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlmorningdojistar(open, high, low, close, penetration: penetration)
      end

      # On-Neck pattern
      def cdl_onneck(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlonneck(open, high, low, close)
      end

      # Rickshaw Man pattern
      def cdl_rickshawman(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlrickshawman(open, high, low, close)
      end

      # Rising/Falling Three Methods pattern
      def cdl_risefall3methods(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlrisefall3methods(open, high, low, close)
      end

      # Separating Lines pattern
      def cdl_separatinglines(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlseparatinglines(open, high, low, close)
      end

      # Short Line Candle pattern
      def cdl_shortline(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlshortline(open, high, low, close)
      end

      # Stalled Pattern
      def cdl_stalledpattern(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlstalledpattern(open, high, low, close)
      end

      # Stick Sandwich pattern
      def cdl_sticksandwich(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlsticksandwich(open, high, low, close)
      end

      # Takuri (Dragonfly Doji with very long lower shadow) pattern
      def cdl_takuri(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdltakuri(open, high, low, close)
      end

      # Tasuki Gap pattern
      def cdl_tasukigap(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdltasukigap(open, high, low, close)
      end

      # Thrusting pattern
      def cdl_thrusting(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlthrusting(open, high, low, close)
      end

      # Tristar pattern
      def cdl_tristar(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdltristar(open, high, low, close)
      end

      # Unique 3 River pattern
      def cdl_unique3river(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlunique3river(open, high, low, close)
      end

      # Upside Gap Two Crows pattern
      def cdl_upsidegap2crows(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlupsidegap2crows(open, high, low, close)
      end

      # Upside/Downside Gap Three Methods pattern
      def cdl_xsidegap3methods(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        TALibFFI.cdlxsidegap3methods(open, high, low, close)
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
