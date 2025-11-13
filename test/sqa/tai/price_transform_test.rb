# frozen_string_literal: true

require "test_helper"

class SQA::TAI::PriceTransformTest < Minitest::Test
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
end
