# frozen_string_literal: true

require "test_helper"

class SQA::TAI::VolumeIndicatorsTest < Minitest::Test
  def test_obv_volume_indicator
    skip "TA-Lib not installed" unless SQA::TAI.available?
    # Fixed by lib/extensions/ta_lib_ffi.rb monkey patch

    result = SQA::TAI.obv(TestData::CLOSE, TestData::VOLUME)

    assert_instance_of Array, result
    refute_empty result
  end

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
end
