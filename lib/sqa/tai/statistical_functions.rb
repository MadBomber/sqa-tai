# frozen_string_literal: true

module SQA
  module TAI
    # Statistical Functions
    module StatisticalFunctions
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
    end
  end
end
