# frozen_string_literal: true

require "test_helper"

class SQA::TAI::PatternRecognitionTest < Minitest::Test
  # Three passes over the sample bars: the patterns' lookback is longer
  # than the 10 bars in TestData, which would leave nothing to check.
  OHLC = [TestData::OPEN, TestData::HIGH, TestData::LOW, TestData::CLOSE].map { it * 3 }.freeze
  SIGNALS = [-100, 0, 100].freeze # bearish, none, bullish

  def setup
    skip "TA-Lib not installed" unless SQA::TAI.available?
  end

  def test_cdl_doji = assert_pattern_signals(:cdl_doji)

  def test_cdl_morningstar = assert_pattern_signals(:cdl_morningstar)

  def test_cdl_eveningstar = assert_pattern_signals(:cdl_eveningstar)

  def test_cdl_harami = assert_pattern_signals(:cdl_harami)

  def test_cdl_hammer = assert_pattern_signals(:cdl_hammer)

  def test_cdl_engulfing = assert_pattern_signals(:cdl_engulfing)

  def test_cdl_shootingstar = assert_pattern_signals(:cdl_shootingstar)

  def test_cdl_3blackcrows = assert_pattern_signals(:cdl_3blackcrows)

  def test_cdl_darkcloudcover = assert_pattern_signals(:cdl_darkcloudcover)

  private

  # A candlestick pattern returns one signal per bar past its lookback:
  # -100, 0 or 100.
  def assert_pattern_signals(pattern)
    result = SQA::TAI.public_send(pattern, *OHLC)

    assert_instance_of Array, result
    refute_empty result
    assert_empty result.compact - SIGNALS, "#{pattern} returned an invalid signal"
  end
end
