# frozen_string_literal: true

module SQA
  module TAI
    # Volume Indicators
    module VolumeIndicators
      # On Balance Volume
      # @param close [Array<Float>] Close prices
      # @param volume [Array<Float>] Volume values
      # @return [Array<Float>] OBV values
      def obv(close, volume)
        check_available!
        validate_prices!(close)
        validate_prices!(volume)

        # OBV's second parameter is a TA_Input_Price bundle consisting of
        # just the VOLUME flag, so it's still wrapped in an array even
        # though it's a single series.
        Native.obv(close, [volume])
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

        Native.ad([high, low, close, volume])
      end

      # Chaikin A/D Oscillator
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @param close [Array<Float>] Close prices
      # @param volume [Array<Float>] Volume values
      # @param fast_period [Integer] Fast period (default: 3)
      # @param slow_period [Integer] Slow period (default: 10)
      # @return [Array<Float>] ADOSC values
      # :reek:LongParameterList -- mirrors TA-Lib's own ADOSC signature;
      # bundling these would be a breaking public API change (see
      # MomentumIndicators/VolatilityIndicators for the fuller rationale).
      def adosc(high, low, close, volume, fast_period: 3, slow_period: 10)
        check_available!
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)
        validate_prices!(volume)

        Native.adosc([high, low, close, volume], fast_period:, slow_period:)
      end
    end
  end
end
