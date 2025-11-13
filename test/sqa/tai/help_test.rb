# frozen_string_literal: true

require "test_helper"

class SQA::TAI::HelpTest < Minitest::Test
  def test_help_returns_resource_for_valid_indicator
    help = SQA::TAI.help(:sma)

    assert_instance_of SQA::TAI::Help::Resource, help
    assert_equal :sma, help.indicator
    assert_equal :overlap_studies, help.category
    assert_match %r{https://madbomber.github.io/sqa-tai/indicators/overlap/sma}, help.url
  end

  def test_help_resource_to_s_returns_formatted_info
    help = SQA::TAI.help(:rsi)
    output = help.to_s

    assert_match(/Indicator: RSI \(RSI\)/, output)
    assert_match(/Category:  Momentum Indicators/, output)
    assert_match(%r{Website:   https://madbomber.github.io/sqa-tai/indicators/momentum/rsi}, output)
  end

  def test_help_resource_uri_returns_uri_object
    help = SQA::TAI.help(:macd)

    assert_instance_of URI::HTTPS, help.uri
    assert_equal help.url, help.uri.to_s
  end

  def test_help_with_format_uri
    result = SQA::TAI.help(:ema, format: :uri)

    assert_instance_of URI::HTTPS, result
  end

  def test_help_with_format_hash
    result = SQA::TAI.help(:bbands, format: :hash)

    assert_instance_of Hash, result
    assert result.key?(:name)
    assert result.key?(:category)
    assert result.key?(:url)
  end

  def test_help_raises_error_for_unknown_indicator
    assert_raises(ArgumentError) do
      SQA::TAI.help(:nonexistent_indicator)
    end
  end

  def test_help_all_returns_hash_of_all_indicators
    result = SQA::TAI.help(:all)

    assert_instance_of Hash, result
    assert result.size > 100 # We have 139 indicators
    assert result.key?(:sma)
    assert result.key?(:rsi)
    assert result.key?(:macd)
    assert result.values.all? { |url| url.start_with?("https://") }
  end

  def test_help_category_returns_indicators_in_category
    result = SQA::TAI.help(category: :momentum_indicators)

    assert_instance_of Hash, result
    assert result.key?(:rsi)
    assert result.key?(:macd)
    refute result.key?(:sma) # SMA is overlap, not momentum
  end

  def test_help_search_by_name
    result = SQA::TAI.help(search: "momentum")

    assert_instance_of Hash, result
    assert result.key?(:mom) # Momentum
    assert result.key?(:cmo) # Chande Momentum Oscillator
  end

  def test_help_search_by_indicator_name
    result = SQA::TAI.help(search: "rsi")

    assert_instance_of Hash, result
    assert result.key?(:rsi)
    assert result.key?(:stochrsi) # Contains "rsi" in name
  end

  def test_help_resource_inspect
    help = SQA::TAI.help(:atr)

    inspect_str = help.inspect
    assert_match(/SQA::TAI::Help::Resource/, inspect_str)
    assert_match(/atr/, inspect_str)
    assert_match(%r{https://}, inspect_str)
  end

  def test_help_resource_name
    help = SQA::TAI.help(:sma)

    assert_equal "SMA", help.name
  end

  def test_help_data_loaded
    # Verify help data is loaded
    refute_empty SQA::TAI::Help.indicators
    assert SQA::TAI::Help.indicators.size > 100
  end

  def test_base_url_configured
    assert_equal "https://madbomber.github.io/sqa-tai", SQA::TAI::Help::BASE_URL
  end

  def test_help_pattern_recognition_indicators
    result = SQA::TAI.help(category: :pattern_recognition)

    assert_instance_of Hash, result
    assert result.key?(:cdl_doji)
    assert result.key?(:cdl_hammer)
  end
end
