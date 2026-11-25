# frozen_string_literal: true

require "test_helper"

class SQA::TAI::VolatilityIndicatorsTest < Minitest::Test
  def test_atr_with_high_low_close
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.atr(TestData::HIGH, TestData::LOW, TestData::CLOSE, period: 5)

    assert_instance_of Array, result
    refute_empty result
    # ATR should always be positive
    assert result.compact.none?(&:negative?), "ATR should be positive"
  end

  def test_natr
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.natr(TestData::HIGH, TestData::LOW, TestData::CLOSE, period: 5)

    assert_instance_of Array, result
    # NATR should always be positive for values that exist
    assert result.compact.none?(&:negative?), "NATR should be positive"
  end

  def test_sar
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.sar(TestData::HIGH, TestData::LOW)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_accbands_returns_three_arrays
    skip "TA-Lib not installed" unless SQA::TAI.available?

    # Use extended test data for better results
    extended_high = TestData::HIGH * 3
    extended_low = TestData::LOW * 3
    extended_close = TestData::CLOSE * 3

    upper, middle, lower = SQA::TAI.accbands(extended_high, extended_low, extended_close, period: 20)
    bands = upper.zip(middle, lower).select(&:all?)

    assert_instance_of Array, upper
    assert_instance_of Array, middle
    assert_instance_of Array, lower
    refute_empty bands
    # Every bar is ordered upper >= middle >= lower
    assert_equal bands.map { it.sort.reverse }, bands
  end

  def test_sarext
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.sarext(TestData::HIGH, TestData::LOW)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_trange
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.trange(TestData::HIGH, TestData::LOW, TestData::CLOSE)

    assert_instance_of Array, result
    refute_empty result
  end
end
