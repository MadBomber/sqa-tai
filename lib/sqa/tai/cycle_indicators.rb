# frozen_string_literal: true

module SQA
  module TAI
    # Cycle Indicators
    module CycleIndicators
      # Hilbert Transform - Dominant Cycle Period
      # @param prices [Array<Float>] Array of prices
      # @return [Array<Float>] Dominant cycle period values
      def ht_dcperiod(prices)
        check_available!
        validate_prices!(prices)

        Native.ht_dcperiod(prices)
      end

      # Hilbert Transform - Trend vs Cycle Mode
      # @param prices [Array<Float>] Array of prices
      # @return [Array<Integer>] Trend mode (1) or cycle mode (0)
      def ht_trendmode(prices)
        check_available!
        validate_prices!(prices)

        Native.ht_trendmode(prices)
      end

      # Hilbert Transform - Dominant Cycle Phase
      # @param prices [Array<Float>] Array of prices
      # @return [Array<Float>] Dominant cycle phase values
      def ht_dcphase(prices)
        check_available!
        validate_prices!(prices)

        Native.ht_dcphase(prices)
      end

      # Hilbert Transform - Phasor Components
      # @param prices [Array<Float>] Array of prices
      # @return [Array<Array<Float>>] [inphase, quadrature]
      def ht_phasor(prices)
        check_available!
        validate_prices!(prices)

        result = Native.ht_phasor(prices)
        [result[:in_phase], result[:quadrature]]
      end

      # Hilbert Transform - SineWave
      # @param prices [Array<Float>] Array of prices
      # @return [Array<Array<Float>>] [sine, lead_sine]
      def ht_sine(prices)
        check_available!
        validate_prices!(prices)

        result = Native.ht_sine(prices)
        [result[:sine], result[:lead_sine]]
      end
    end
  end
end
