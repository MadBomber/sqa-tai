# frozen_string_literal: true

require "test_helper"

class SQA::TAI::PatternRecognitionTest < Minitest::Test
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
