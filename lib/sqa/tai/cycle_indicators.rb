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
    end
  end
end
