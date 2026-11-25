# frozen_string_literal: true

require "test_helper"

class SQA::TAI::OverlapStudiesTest < Minitest::Test
  def test_sma_basic
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.sma(TestData::PRICES, period: 5)

    assert_instance_of Array, result
    refute_empty result
    assert(result.all?(Numeric))
  end

  def test_ema_basic
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.ema(TestData::PRICES, period: 5)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_wma
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.wma(TestData::PRICES, period: 5)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_dema
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.dema(TestData::PRICES, period: 5)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_tema
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.tema(TestData::PRICES, period: 5)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_trima
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.trima(TestData::PRICES, period: 5)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_kama
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.kama(TestData::PRICES, period: 5)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_t3
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.t3(TestData::PRICES, period: 5)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_bbands_returns_three_arrays
    skip "TA-Lib not installed" unless SQA::TAI.available?

    upper, middle, lower = SQA::TAI.bbands(TestData::PRICES, period: 5)
    bands = upper.zip(middle, lower).select(&:all?)

    assert_instance_of Array, upper
    assert_instance_of Array, middle
    assert_instance_of Array, lower
    refute_empty bands
    # Every bar is ordered upper >= middle >= lower
    assert_equal bands.map { it.sort.reverse }, bands
  end

  def test_ma_as_sma
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.ma(TestData::PRICES, period: 5, ma_type: 0)

    refute_empty result
    assert_equal SQA::TAI.sma(TestData::PRICES, period: 5), result
  end

  def test_ma_as_ema
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.ma(TestData::PRICES, period: 5, ma_type: 1)

    refute_empty result
    assert_equal SQA::TAI.ema(TestData::PRICES, period: 5), result
  end

  def test_ma_as_wma
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.ma(TestData::PRICES, period: 5, ma_type: 2)

    refute_empty result
    assert_equal SQA::TAI.wma(TestData::PRICES, period: 5), result
  end
end
