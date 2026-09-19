# frozen_string_literal: true

module SQA
  module TAI
    # Price Transform
    #
    # :reek:DataClump -- these methods intentionally mirror TA-Lib's own
    # C function signatures (high/low/close as separate positional args);
    # bundling them into a value object would be a breaking public API
    # change for this gem and its downstream consumers (sqa, sqa-cli,
    # sqa-advisor) and their 133 published indicator doc pages.
    module PriceTransform
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

        Native.avgprice([open, high, low, close])
      end

      # Median Price
      # @param high [Array<Float>] High prices
      # @param low [Array<Float>] Low prices
      # @return [Array<Float>] Median price values
      def medprice(high, low)
        check_available!
        validate_prices!(high)
        validate_prices!(low)

        Native.medprice([high, low])
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

        Native.typprice([high, low, close])
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

        Native.wclprice([high, low, close])
      end
    end
  end
end
