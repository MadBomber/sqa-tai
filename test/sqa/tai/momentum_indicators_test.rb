# frozen_string_literal: true

require "test_helper"

class SQA::TAI::MomentumIndicatorsTest < Minitest::Test
  def test_rsi_basic
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.rsi(TestData::PRICES, period: 14)

    assert_instance_of Array, result
    refute_empty result
    # RSI values should be between 0 and 100
    result.compact.each do |value|
      assert value >= 0 && value <= 100, "RSI value #{value} out of range"
    end
  end

  def test_macd_returns_three_arrays
    skip "TA-Lib not installed" unless SQA::TAI.available?

    macd, signal, histogram = SQA::TAI.macd(TestData::PRICES)

    assert_instance_of Array, macd
    assert_instance_of Array, signal
    assert_instance_of Array, histogram
  end

  def test_stoch_oscillator
    skip "TA-Lib not installed" unless SQA::TAI.available?
    # Fixed by lib/extensions/ta_lib_ffi.rb monkey patch

    slowk, slowd = SQA::TAI.stoch(
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

  def test_cci
    skip "TA-Lib not installed" unless SQA::TAI.available?
    # Fixed by lib/extensions/ta_lib_ffi.rb monkey patch

    result = SQA::TAI.cci(TestData::HIGH, TestData::LOW, TestData::CLOSE, period: 5)

    assert_instance_of Array, result
    # CCI may return empty for small datasets, just verify it returns an array
  end

  def test_willr
    skip "TA-Lib not installed" unless SQA::TAI.available?
    # Fixed by lib/extensions/ta_lib_ffi.rb monkey patch

    result = SQA::TAI.willr(TestData::HIGH, TestData::LOW, TestData::CLOSE, period: 5)

    assert_instance_of Array, result
    # Williams %R should be between -100 and 0 for values that exist
    result.compact.each do |value|
      assert value >= -100 && value <= 0, "WILLR value out of range"
    end
  end

  def test_roc
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.roc(TestData::PRICES, period: 10)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_rocp
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.rocp(TestData::PRICES, period: 10)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_rocr
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.rocr(TestData::PRICES, period: 10)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_ppo
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.ppo(TestData::PRICES)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_adx
    skip "TA-Lib not installed" unless SQA::TAI.available?
    # Fixed by lib/extensions/ta_lib_ffi.rb monkey patch

    result = SQA::TAI.adx(TestData::HIGH, TestData::LOW, TestData::CLOSE, period: 5)

    assert_instance_of Array, result
    # ADX should be between 0 and 100 for values that exist
    result.compact.each do |value|
      assert value >= 0 && value <= 100, "ADX value out of range"
    end
  end

  def test_adxr
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.adxr(TestData::HIGH, TestData::LOW, TestData::CLOSE, period: 5)

    assert_instance_of Array, result
  end

  def test_apo
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.apo(TestData::PRICES)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_aroon
    skip "TA-Lib not installed" unless SQA::TAI.available?

    aroon_down, aroon_up = SQA::TAI.aroon(TestData::HIGH, TestData::LOW, period: 5)

    assert_instance_of Array, aroon_down
    assert_instance_of Array, aroon_up
  end

  def test_aroonosc
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.aroonosc(TestData::HIGH, TestData::LOW, period: 5)

    assert_instance_of Array, result
  end

  def test_bop
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.bop(
      TestData::OPEN,
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE
    )

    assert_instance_of Array, result
    refute_empty result
  end

  def test_cmo
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.cmo(TestData::PRICES, period: 14)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_mfi
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.mfi(
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE,
      TestData::VOLUME,
      period: 5
    )

    assert_instance_of Array, result
  end

  def test_mom
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.mom(TestData::PRICES, period: 10)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_trix
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.trix(TestData::PRICES, period: 30)

    assert_instance_of Array, result
  end

  def test_ultosc
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.ultosc(
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE
    )

    assert_instance_of Array, result
  end

  def test_stochf
    skip "TA-Lib not installed" unless SQA::TAI.available?

    fastk, fastd = SQA::TAI.stochf(
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE
    )

    assert_instance_of Array, fastk
    assert_instance_of Array, fastd
  end

  def test_stochrsi
    skip "TA-Lib not installed" unless SQA::TAI.available?

    fastk, fastd = SQA::TAI.stochrsi(TestData::PRICES, period: 14)

    assert_instance_of Array, fastk
    assert_instance_of Array, fastd
  end

  def test_imi_with_open_close
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.imi(TestData::OPEN, TestData::CLOSE, period: 5)

    assert_instance_of Array, result
    refute_empty result
    # IMI values should be between 0 and 100 (like RSI)
    result.compact.each do |value|
      assert value >= 0 && value <= 100, "IMI value #{value} out of range"
    end
  end
end
