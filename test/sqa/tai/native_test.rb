# frozen_string_literal: true

require "test_helper"

class SQA::TAI::NativeTest < Minitest::Test
  N = SQA::TAI::Native

  # Regression guard: TA-Lib's C ABI has changed the TA_FuncInfo struct
  # layout before (dropping a field the previous binding assumed existed),
  # which corrupted nbInput/nbOptInput/nbOutput reads and made every
  # introspection call spin forever allocating memory instead of failing
  # fast. If this ever hangs or returns nonsense, the struct in native.rb
  # no longer matches the installed TA-Lib header.
  def test_function_info_reads_correct_struct_layout
    skip "TA-Lib not installed" unless N.available?

    info = N.function_info("ATR")

    refute_nil info
    assert_equal "ATR", info.name
    assert_equal 1, info.inputs.length
    assert_equal 1, info.opt_inputs.length
    assert_equal 1, info.outputs.length
  end

  def test_unknown_function_returns_nil_info
    skip "TA-Lib not installed" unless N.available?

    assert_nil N.function_info("NOT_A_REAL_TA_LIB_FUNCTION")
    refute N.respond_to?(:not_a_real_ta_lib_function)
  end

  def test_single_output_real_input_call
    skip "TA-Lib not installed" unless N.available?

    result = N.sma(TestData::CLOSE, time_period: 3)

    assert_instance_of Array, result
    refute_empty result
  end

  def test_price_bundle_input_call
    skip "TA-Lib not installed" unless N.available?

    result = N.atr([TestData::HIGH, TestData::LOW, TestData::CLOSE], time_period: 5)

    assert_instance_of Array, result
    result.compact.each { |value| assert value >= 0, "ATR should be positive" }
  end

  def test_multi_output_call_returns_hash
    skip "TA-Lib not installed" unless N.available?

    result = N.bbands(TestData::CLOSE, time_period: 5, nbdev_up: 2.0, nbdev_dn: 2.0)

    assert_instance_of Hash, result
    assert_includes result.keys, :upper_band
    assert_includes result.keys, :middle_band
    assert_includes result.keys, :lower_band
  end
end
