# frozen_string_literal: true

module SQA
  module TAI
    # Pattern Recognition (Candlestick Patterns)
    #
    # :reek:DataClump -- all 61 patterns intentionally take TA-Lib's own
    # OHLC (+ optional penetration) signature as separate positional args;
    # bundling them into a value object would be a breaking public API
    # change for this gem and its downstream consumers (sqa, sqa-cli,
    # sqa-advisor) and their 133 published indicator doc pages.
    module PatternRecognition
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

        Native.cdldoji([open, high, low, close])
      end

      # Hammer candlestick pattern
      def cdl_hammer(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlhammer([open, high, low, close])
      end

      # Engulfing pattern
      def cdl_engulfing(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlengulfing([open, high, low, close])
      end

      # Morning Star pattern
      def cdl_morningstar(open, high, low, close, penetration: 0.3)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlmorningstar([open, high, low, close], penetration: penetration)
      end

      # Evening Star pattern
      def cdl_eveningstar(open, high, low, close, penetration: 0.3)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdleveningstar([open, high, low, close], penetration: penetration)
      end

      # Harami pattern
      def cdl_harami(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlharami([open, high, low, close])
      end

      # Piercing pattern
      def cdl_piercing(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlpiercing([open, high, low, close])
      end

      # Shooting Star pattern
      def cdl_shootingstar(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlshootingstar([open, high, low, close])
      end

      # Marubozu pattern
      def cdl_marubozu(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlmarubozu([open, high, low, close])
      end

      # Spinning Top pattern
      def cdl_spinningtop(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlspinningtop([open, high, low, close])
      end

      # Dragonfly Doji pattern
      def cdl_dragonflydoji(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdldragonflydoji([open, high, low, close])
      end

      # Gravestone Doji pattern
      def cdl_gravestonedoji(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlgravestonedoji([open, high, low, close])
      end

      # Two Crows pattern
      def cdl_2crows(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdl2crows([open, high, low, close])
      end

      # Three Black Crows pattern
      def cdl_3blackcrows(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdl3blackcrows([open, high, low, close])
      end

      # Three Inside Up/Down pattern
      def cdl_3inside(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdl3inside([open, high, low, close])
      end

      # Three Line Strike pattern
      def cdl_3linestrike(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdl3linestrike([open, high, low, close])
      end

      # Three Outside Up/Down pattern
      def cdl_3outside(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdl3outside([open, high, low, close])
      end

      # Three Stars In The South pattern
      def cdl_3starsinsouth(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdl3starsinsouth([open, high, low, close])
      end

      # Three Advancing White Soldiers pattern
      def cdl_3whitesoldiers(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdl3whitesoldiers([open, high, low, close])
      end

      # Abandoned Baby pattern
      def cdl_abandonedbaby(open, high, low, close, penetration: 0.3)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlabandonedbaby([open, high, low, close], penetration: penetration)
      end

      # Advance Block pattern
      def cdl_advanceblock(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdladvanceblock([open, high, low, close])
      end

      # Belt-hold pattern
      def cdl_belthold(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlbelthold([open, high, low, close])
      end

      # Breakaway pattern
      def cdl_breakaway(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlbreakaway([open, high, low, close])
      end

      # Closing Marubozu pattern
      def cdl_closingmarubozu(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlclosingmarubozu([open, high, low, close])
      end

      # Concealing Baby Swallow pattern
      def cdl_concealbabyswall(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlconcealbabyswall([open, high, low, close])
      end

      # Counterattack pattern
      def cdl_counterattack(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlcounterattack([open, high, low, close])
      end

      # Dark Cloud Cover pattern
      def cdl_darkcloudcover(open, high, low, close, penetration: 0.5)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdldarkcloudcover([open, high, low, close], penetration: penetration)
      end

      # Doji Star pattern
      def cdl_dojistar(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdldojistar([open, high, low, close])
      end

      # Evening Doji Star pattern
      def cdl_eveningdojistar(open, high, low, close, penetration: 0.3)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdleveningdojistar([open, high, low, close], penetration: penetration)
      end

      # Up/Down-gap side-by-side white lines pattern
      def cdl_gapsidesidewhite(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlgapsidesidewhite([open, high, low, close])
      end

      # Hanging Man pattern
      def cdl_hangingman(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlhangingman([open, high, low, close])
      end

      # Harami Cross pattern
      def cdl_haramicross(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlharamicross([open, high, low, close])
      end

      # High-Wave Candle pattern
      def cdl_highwave(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlhighwave([open, high, low, close])
      end

      # Hikkake pattern
      def cdl_hikkake(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlhikkake([open, high, low, close])
      end

      # Modified Hikkake pattern
      def cdl_hikkakemod(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlhikkakemod([open, high, low, close])
      end

      # Homing Pigeon pattern
      def cdl_homingpigeon(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlhomingpigeon([open, high, low, close])
      end

      # Identical Three Crows pattern
      def cdl_identical3crows(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlidentical3crows([open, high, low, close])
      end

      # In-Neck pattern
      def cdl_inneck(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlinneck([open, high, low, close])
      end

      # Inverted Hammer pattern
      def cdl_invertedhammer(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlinvertedhammer([open, high, low, close])
      end

      # Kicking pattern
      def cdl_kicking(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlkicking([open, high, low, close])
      end

      # Kicking - bull/bear determined by the longer marubozu
      def cdl_kickingbylength(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlkickingbylength([open, high, low, close])
      end

      # Ladder Bottom pattern
      def cdl_ladderbottom(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlladderbottom([open, high, low, close])
      end

      # Long Legged Doji pattern
      def cdl_longleggeddoji(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdllongleggeddoji([open, high, low, close])
      end

      # Long Line Candle pattern
      def cdl_longline(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdllongline([open, high, low, close])
      end

      # Matching Low pattern
      def cdl_matchinglow(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlmatchinglow([open, high, low, close])
      end

      # Mat Hold pattern
      def cdl_mathold(open, high, low, close, penetration: 0.5)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlmathold([open, high, low, close], penetration: penetration)
      end

      # Morning Doji Star pattern
      def cdl_morningdojistar(open, high, low, close, penetration: 0.3)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlmorningdojistar([open, high, low, close], penetration: penetration)
      end

      # On-Neck pattern
      def cdl_onneck(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlonneck([open, high, low, close])
      end

      # Rickshaw Man pattern
      def cdl_rickshawman(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlrickshawman([open, high, low, close])
      end

      # Rising/Falling Three Methods pattern
      def cdl_risefall3methods(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlrisefall3methods([open, high, low, close])
      end

      # Separating Lines pattern
      def cdl_separatinglines(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlseparatinglines([open, high, low, close])
      end

      # Short Line Candle pattern
      def cdl_shortline(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlshortline([open, high, low, close])
      end

      # Stalled Pattern
      def cdl_stalledpattern(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlstalledpattern([open, high, low, close])
      end

      # Stick Sandwich pattern
      def cdl_sticksandwich(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlsticksandwich([open, high, low, close])
      end

      # Takuri (Dragonfly Doji with very long lower shadow) pattern
      def cdl_takuri(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdltakuri([open, high, low, close])
      end

      # Tasuki Gap pattern
      def cdl_tasukigap(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdltasukigap([open, high, low, close])
      end

      # Thrusting pattern
      def cdl_thrusting(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlthrusting([open, high, low, close])
      end

      # Tristar pattern
      def cdl_tristar(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdltristar([open, high, low, close])
      end

      # Unique 3 River pattern
      def cdl_unique3river(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlunique3river([open, high, low, close])
      end

      # Upside Gap Two Crows pattern
      def cdl_upsidegap2crows(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlupsidegap2crows([open, high, low, close])
      end

      # Upside/Downside Gap Three Methods pattern
      def cdl_xsidegap3methods(open, high, low, close)
        check_available!
        validate_prices!(open)
        validate_prices!(high)
        validate_prices!(low)
        validate_prices!(close)

        Native.cdlxsidegap3methods([open, high, low, close])
      end
    end
  end
end
