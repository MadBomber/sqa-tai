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
end
