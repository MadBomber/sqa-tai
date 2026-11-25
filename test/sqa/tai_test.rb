# frozen_string_literal: true

require "test_helper"

class SQA::TAITest < Minitest::Test
  def test_version
    refute_nil ::SQA::TAI::VERSION
    assert_match(/\d+\.\d+\.\d+/, ::SQA::TAI::VERSION)
  end

  def test_module_exists
    assert_kind_of Module, SQA::TAI
    assert_respond_to SQA::TAI, :sma
  end

  def test_availability_check
    # Should return true or false, not raise
    assert_includes [true, false], SQA::TAI.available?
  end

  def test_empty_array_is_invalid
    skip "TA-Lib not installed" unless SQA::TAI.available?

    error = assert_raises(SQA::TAI::InvalidParameterError) { SQA::TAI.sma([], period: 5) }

    assert_match(/cannot be empty/, error.message)
  end

  def test_nil_array_is_invalid
    skip "TA-Lib not installed" unless SQA::TAI.available?

    error = assert_raises(SQA::TAI::InvalidParameterError) { SQA::TAI.sma(nil, period: 5) }

    assert_match(/cannot be nil/, error.message)
  end

  def test_period_larger_than_data_is_invalid
    skip "TA-Lib not installed" unless SQA::TAI.available?

    error = assert_raises(SQA::TAI::InvalidParameterError) { SQA::TAI.sma([1, 2, 3], period: 10) }

    assert_match(/cannot exceed data size/, error.message)
  end

  def test_negative_period_is_invalid
    skip "TA-Lib not installed" unless SQA::TAI.available?

    error = assert_raises(SQA::TAI::InvalidParameterError) { SQA::TAI.sma(TestData::PRICES, period: -5) }

    assert_match(/must be positive/, error.message)
  end
end
