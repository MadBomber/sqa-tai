# frozen_string_literal: true

require "test_helper"

class SQA::TAI::OverlapStudiesTest < Minitest::Test
  def test_sma_basic
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.sma(TestData::PRICES, period: 5)

    assert_instance_of Array, result
    refute_empty result
    assert result.all? { |v| v.is_a?(Numeric) }
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

    assert_instance_of Array, upper
    assert_instance_of Array, middle
    assert_instance_of Array, lower

    # Upper should be greater than middle, middle greater than lower
    upper.compact.zip(middle.compact, lower.compact).each do |u, m, l|
      assert u >= m if u && m
      assert m >= l if m && l
    end
  end

  def test_ma_generic_moving_average
    skip "TA-Lib not installed" unless SQA::TAI.available?

    # Test SMA (ma_type: 0)
    result_sma = SQA::TAI.ma(TestData::PRICES, period: 5, ma_type: 0)
    assert_instance_of Array, result_sma
    refute_empty result_sma

    # Test EMA (ma_type: 1)
    result_ema = SQA::TAI.ma(TestData::PRICES, period: 5, ma_type: 1)
    assert_instance_of Array, result_ema
    refute_empty result_ema

    # Test WMA (ma_type: 2)
    result_wma = SQA::TAI.ma(TestData::PRICES, period: 5, ma_type: 2)
    assert_instance_of Array, result_wma
    refute_empty result_wma

    # All should return arrays of the same length
    assert_equal result_sma.length, result_ema.length
    assert_equal result_ema.length, result_wma.length
  end
end
