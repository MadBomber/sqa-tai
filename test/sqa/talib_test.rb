# frozen_string_literal: true

require "test_helper"

class SQA::TALibTest < Minitest::Test
  def test_version
    refute_nil ::SQA::TALib::VERSION
    assert_match(/\d+\.\d+\.\d+/, ::SQA::TALib::VERSION)
  end

  def test_module_exists
    assert defined?(SQA::TALib)
  end

  def test_availability_check
    # Should return true or false, not raise
    result = SQA::TALib.available?
    assert [true, false].include?(result)
  end

  def test_sma_basic
    skip "TA-Lib not installed" unless SQA::TALib.available?

    result = SQA::TALib.sma(TestData::PRICES, period: 5)

    assert_instance_of Array, result
    refute_empty result
    assert result.all? { |v| v.is_a?(Numeric) }
  end

  def test_ema_basic
    skip "TA-Lib not installed" unless SQA::TALib.available?

    result = SQA::TALib.ema(TestData::PRICES, period: 5)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_rsi_basic
    skip "TA-Lib not installed" unless SQA::TALib.available?

    result = SQA::TALib.rsi(TestData::PRICES, period: 14)

    assert_instance_of Array, result
    refute_empty result
    # RSI values should be between 0 and 100
    result.compact.each do |value|
      assert value >= 0 && value <= 100, "RSI value #{value} out of range"
    end
  end

  def test_macd_returns_three_arrays
    skip "TA-Lib not installed" unless SQA::TALib.available?

    macd, signal, histogram = SQA::TALib.macd(TestData::PRICES)

    assert_instance_of Array, macd
    assert_instance_of Array, signal
    assert_instance_of Array, histogram
  end

  def test_bbands_returns_three_arrays
    skip "TA-Lib not installed" unless SQA::TALib.available?

    upper, middle, lower = SQA::TALib.bbands(TestData::PRICES, period: 5)

    assert_instance_of Array, upper
    assert_instance_of Array, middle
    assert_instance_of Array, lower

    # Upper should be greater than middle, middle greater than lower
    upper.compact.zip(middle.compact, lower.compact).each do |u, m, l|
      assert u >= m if u && m
      assert m >= l if m && l
    end
  end

  def test_atr_with_high_low_close
    skip "TA-Lib not installed" unless SQA::TALib.available?

    result = SQA::TALib.atr(TestData::HIGH, TestData::LOW, TestData::CLOSE, period: 5)

    assert_instance_of Array, result
    refute_empty result
    # ATR should always be positive
    result.compact.each do |value|
      assert value >= 0, "ATR should be positive"
    end
  end

  def test_invalid_parameters
    skip "TA-Lib not installed" unless SQA::TALib.available?

    # Empty array
    assert_raises(SQA::TALib::InvalidParameterError) do
      SQA::TALib.sma([], period: 5)
    end

    # Nil array
    assert_raises(SQA::TALib::InvalidParameterError) do
      SQA::TALib.sma(nil, period: 5)
    end

    # Period larger than data
    assert_raises(SQA::TALib::InvalidParameterError) do
      SQA::TALib.sma([1, 2, 3], period: 10)
    end

    # Negative period
    assert_raises(SQA::TALib::InvalidParameterError) do
      SQA::TALib.sma(TestData::PRICES, period: -5)
    end
  end

  def test_pattern_recognition
    skip "TA-Lib not installed" unless SQA::TALib.available?

    result = SQA::TALib.cdl_doji(
      TestData::OPEN,
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE
    )

    assert_instance_of Array, result
    # Pattern results should be -100, 0, or 100
    result.compact.each do |value|
      assert [-100, 0, 100].include?(value), "Pattern value #{value} invalid"
    end
  end

  def test_obv_volume_indicator
    skip "TA-Lib not installed" unless SQA::TALib.available?

    result = SQA::TALib.obv(TestData::CLOSE, TestData::VOLUME)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_stoch_oscillator
    skip "TA-Lib not installed" unless SQA::TALib.available?

    slowk, slowd = SQA::TALib.stoch(
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE
    )

    assert_instance_of Array, slowk
    assert_instance_of Array, slowd

    # Stochastic values should be between 0 and 100
    slowk.compact.each do |value|
      assert value >= 0 && value <= 100, "Stoch K value out of range"
    end
  end
end
