# frozen_string_literal: true

require "test_helper"

class SQA::TAI::CycleIndicatorsTest < Minitest::Test
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
end
