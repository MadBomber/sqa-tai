# frozen_string_literal: true

require "test_helper"

class SQA::TAI::StatisticalFunctionsTest < Minitest::Test
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
end
