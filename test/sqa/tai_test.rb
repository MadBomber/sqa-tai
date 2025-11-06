# frozen_string_literal: true

require "test_helper"

class SQA::TAITest < Minitest::Test
  def test_version
    refute_nil ::SQA::TAI::VERSION
    assert_match(/\d+\.\d+\.\d+/, ::SQA::TAI::VERSION)
  end

  def test_module_exists
    assert defined?(SQA::TAI)
  end

  def test_availability_check
    # Should return true or false, not raise
    result = SQA::TAI.available?
    assert [true, false].include?(result)
  end

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

  def test_atr_with_high_low_close
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.atr(TestData::HIGH, TestData::LOW, TestData::CLOSE, period: 5)

    assert_instance_of Array, result
    refute_empty result
    # ATR should always be positive
    result.compact.each do |value|
      assert value >= 0, "ATR should be positive"
    end
  end

  def test_accbands_returns_three_arrays
    skip "TA-Lib not installed" unless SQA::TAI.available?

    # Use extended test data for better results
    extended_high = TestData::HIGH * 3
    extended_low = TestData::LOW * 3
    extended_close = TestData::CLOSE * 3

    upper, middle, lower = SQA::TAI.accbands(extended_high, extended_low, extended_close, period: 20)

    assert_instance_of Array, upper
    assert_instance_of Array, middle
    assert_instance_of Array, lower

    # Upper should be greater than middle, middle greater than lower
    upper.compact.zip(middle.compact, lower.compact).each do |u, m, l|
      assert u >= m if u && m
      assert m >= l if m && l
    end
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

  def test_invalid_parameters
    skip "TA-Lib not installed" unless SQA::TAI.available?

    # Empty array
    assert_raises(SQA::TAI::InvalidParameterError) do
      SQA::TAI.sma([], period: 5)
    end

    # Nil array
    assert_raises(SQA::TAI::InvalidParameterError) do
      SQA::TAI.sma(nil, period: 5)
    end

    # Period larger than data
    assert_raises(SQA::TAI::InvalidParameterError) do
      SQA::TAI.sma([1, 2, 3], period: 10)
    end

    # Negative period
    assert_raises(SQA::TAI::InvalidParameterError) do
      SQA::TAI.sma(TestData::PRICES, period: -5)
    end
  end

  def test_pattern_recognition
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.cdl_doji(
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
    skip "TA-Lib not installed" unless SQA::TAI.available?
    # Fixed by lib/extensions/ta_lib_ffi.rb monkey patch

    result = SQA::TAI.obv(TestData::CLOSE, TestData::VOLUME)

    assert_instance_of Array, result
    refute_empty result
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

  # ========================================
  # Tests for New Moving Averages
  # ========================================

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

  # ========================================
  # Tests for New Momentum Indicators
  # ========================================

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

  # ========================================
  # Tests for New Volatility Indicators
  # ========================================

  def test_natr
    skip "TA-Lib not installed" unless SQA::TAI.available?
    # Fixed by lib/extensions/ta_lib_ffi.rb monkey patch

    result = SQA::TAI.natr(TestData::HIGH, TestData::LOW, TestData::CLOSE, period: 5)

    assert_instance_of Array, result
    # NATR should always be positive for values that exist
    result.compact.each do |value|
      assert value >= 0, "NATR should be positive"
    end
  end

  def test_sar
    skip "TA-Lib not installed" unless SQA::TAI.available?
    # Fixed by lib/extensions/ta_lib_ffi.rb monkey patch

    result = SQA::TAI.sar(TestData::HIGH, TestData::LOW)

    assert_instance_of Array, result
    refute_empty result
  end

  # ========================================
  # Tests for Cycle Indicators
  # ========================================

  def test_ht_dcperiod
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.ht_dcperiod(TestData::PRICES)

    assert_instance_of Array, result
    # HT indicators need lots of data, may return empty for small datasets
    # Just verify it returns an array without error
  end

  def test_ht_trendmode
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.ht_trendmode(TestData::PRICES)

    assert_instance_of Array, result
    # HT indicators need lots of data, may return empty for small datasets
    # Trend mode should be 0 or 1 when values exist
    result.compact.each do |value|
      assert [0, 1].include?(value), "HT_TRENDMODE should be 0 or 1"
    end
  end

  # ========================================
  # Tests for Statistical Functions
  # ========================================

  def test_correl
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.correl(TestData::PRICES, TestData::CLOSE, period: 10)

    assert_instance_of Array, result
    refute_empty result
    # Correlation should be between -1 and 1
    result.compact.each do |value|
      assert value >= -1 && value <= 1, "CORREL value out of range"
    end
  end

  def test_beta
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.beta(TestData::PRICES, TestData::CLOSE, period: 5)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_var
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.var(TestData::PRICES, period: 5)

    assert_instance_of Array, result
    refute_empty result
    # Variance should always be positive
    result.compact.each do |value|
      assert value >= 0, "VAR should be positive"
    end
  end

  def test_stddev
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.stddev(TestData::PRICES, period: 5)

    assert_instance_of Array, result
    refute_empty result
    # StdDev should always be positive
    result.compact.each do |value|
      assert value >= 0, "STDDEV should be positive"
    end
  end

  def test_linearreg
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.linearreg(TestData::PRICES, period: 14)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_linearreg_angle
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.linearreg_angle(TestData::PRICES, period: 14)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_linearreg_slope
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.linearreg_slope(TestData::PRICES, period: 14)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_tsf
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.tsf(TestData::PRICES, period: 14)

    assert_instance_of Array, result
    refute_empty result
  end

  # ========================================
  # Tests for Price Transform Indicators
  # ========================================

  def test_avgprice
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.avgprice(
      TestData::OPEN,
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE
    )

    assert_instance_of Array, result
    refute_empty result
  end

  def test_medprice
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.medprice(TestData::HIGH, TestData::LOW)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_typprice
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.typprice(TestData::HIGH, TestData::LOW, TestData::CLOSE)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_wclprice
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.wclprice(TestData::HIGH, TestData::LOW, TestData::CLOSE)

    assert_instance_of Array, result
    refute_empty result
  end

  # ========================================
  # Tests for Additional Momentum Indicators
  # ========================================

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

  # ========================================
  # Tests for Additional Overlap Studies
  # ========================================

  def test_sarext
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.sarext(TestData::HIGH, TestData::LOW)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_ht_trendline
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.ht_trendline(TestData::PRICES)

    assert_instance_of Array, result
  end

  def test_mama
    skip "TA-Lib not installed" unless SQA::TAI.available?

    mama, fama = SQA::TAI.mama(TestData::PRICES)

    assert_instance_of Array, mama
    assert_instance_of Array, fama
  end

  def test_midpoint
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.midpoint(TestData::PRICES, period: 14)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_midprice
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.midprice(TestData::HIGH, TestData::LOW, period: 5)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_wma
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.wma(TestData::PRICES, period: 5)

    assert_instance_of Array, result
    refute_empty result
  end

  # ========================================
  # Tests for Additional Cycle Indicators
  # ========================================

  def test_ht_dcphase
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.ht_dcphase(TestData::PRICES)

    assert_instance_of Array, result
  end

  def test_ht_phasor
    skip "TA-Lib not installed" unless SQA::TAI.available?

    inphase, quadrature = SQA::TAI.ht_phasor(TestData::PRICES)

    assert_instance_of Array, inphase
    assert_instance_of Array, quadrature
  end

  def test_ht_sine
    skip "TA-Lib not installed" unless SQA::TAI.available?

    sine, lead_sine = SQA::TAI.ht_sine(TestData::PRICES)

    assert_instance_of Array, sine
    assert_instance_of Array, lead_sine
  end

  # ========================================
  # Tests for Volume Indicators
  # ========================================

  def test_ad
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.ad(
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE,
      TestData::VOLUME
    )

    assert_instance_of Array, result
    refute_empty result
  end

  def test_adosc
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.adosc(
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE,
      TestData::VOLUME
    )

    assert_instance_of Array, result
  end

  def test_trange
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.trange(TestData::HIGH, TestData::LOW, TestData::CLOSE)

    assert_instance_of Array, result
    refute_empty result
  end

  # ========================================
  # Tests for New Candlestick Patterns
  # ========================================

  def test_cdl_morningstar
    skip "TA-Lib not installed" unless SQA::TAI.available?
    # Fixed by lib/extensions/ta_lib_ffi.rb monkey patch

    result = SQA::TAI.cdl_morningstar(
      TestData::OPEN,
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE
    )

    assert_instance_of Array, result
    result.compact.each do |value|
      assert [-100, 0, 100].include?(value), "Pattern value invalid"
    end
  end

  def test_cdl_eveningstar
    skip "TA-Lib not installed" unless SQA::TAI.available?
    # Fixed by lib/extensions/ta_lib_ffi.rb monkey patch

    result = SQA::TAI.cdl_eveningstar(
      TestData::OPEN,
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE
    )

    assert_instance_of Array, result
    result.compact.each do |value|
      assert [-100, 0, 100].include?(value), "Pattern value invalid"
    end
  end

  def test_cdl_harami
    skip "TA-Lib not installed" unless SQA::TAI.available?
    # Fixed by lib/extensions/ta_lib_ffi.rb monkey patch

    result = SQA::TAI.cdl_harami(
      TestData::OPEN,
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE
    )

    assert_instance_of Array, result
    result.compact.each do |value|
      assert [-100, 0, 100].include?(value), "Pattern value invalid"
    end
  end

  def test_cdl_hammer
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.cdl_hammer(
      TestData::OPEN,
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE
    )

    assert_instance_of Array, result
    result.compact.each do |value|
      assert [-100, 0, 100].include?(value), "Pattern value invalid"
    end
  end

  def test_cdl_engulfing
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.cdl_engulfing(
      TestData::OPEN,
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE
    )

    assert_instance_of Array, result
    result.compact.each do |value|
      assert [-100, 0, 100].include?(value), "Pattern value invalid"
    end
  end

  def test_cdl_shootingstar
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.cdl_shootingstar(
      TestData::OPEN,
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE
    )

    assert_instance_of Array, result
    result.compact.each do |value|
      assert [-100, 0, 100].include?(value), "Pattern value invalid"
    end
  end

  def test_cdl_3blackcrows
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.cdl_3blackcrows(
      TestData::OPEN,
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE
    )

    assert_instance_of Array, result
    result.compact.each do |value|
      assert [-100, 0, 100].include?(value), "Pattern value invalid"
    end
  end

  def test_cdl_darkcloudcover
    skip "TA-Lib not installed" unless SQA::TAI.available?

    result = SQA::TAI.cdl_darkcloudcover(
      TestData::OPEN,
      TestData::HIGH,
      TestData::LOW,
      TestData::CLOSE
    )

    assert_instance_of Array, result
    result.compact.each do |value|
      assert [-100, 0, 100].include?(value), "Pattern value invalid"
    end
  end
end
