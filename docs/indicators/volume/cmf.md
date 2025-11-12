# CMF (Chaikin Money Flow)

> **Note**: CMF (Chaikin Money Flow) is not a standard TA-Lib indicator and is not currently available in SQA::TAI. This page is provided for reference purposes as CMF is commonly used alongside other volume indicators. However, similar functionality is available through [ADOSC (Chaikin A/D Oscillator)](adosc.md).

## Overview

Chaikin Money Flow (CMF) is a volume-weighted average of accumulation and distribution over a specified period. Created by Marc Chaikin, it measures the amount of Money Flow Volume over a specific period, helping traders identify buying and selling pressure.

## What is Chaikin Money Flow?

CMF oscillates between -1 and +1, with:
- **Positive values**: Buying pressure (accumulation)
- **Negative values**: Selling pressure (distribution)
- **Zero line**: Equilibrium between buyers and sellers

Unlike the unbounded [Accumulation/Distribution Line (AD)](ad.md), CMF is normalized and bounded, making it easier to compare across different securities and time periods.

### Formula

```
Money Flow Multiplier = ((Close - Low) - (High - Close)) / (High - Low)
Money Flow Volume = Money Flow Multiplier × Volume
CMF = Sum(Money Flow Volume, N periods) / Sum(Volume, N periods)

Typical Period: 20 or 21 days
```

## Typical Usage

If CMF were available, it would be used like this:

```ruby
# Hypothetical usage (NOT currently available in SQA::TAI)
require 'sqa/tai'

# Note: This functionality is not implemented
# cmf = SQA::TAI.cmf(high, low, close, volume, period: 20)

# Manual calculation approach:
def calculate_cmf(high, low, close, volume, period = 20)
  # Calculate money flow multiplier
  mf_multiplier = high.zip(low, close).map do |h, l, c|
    next 0 if h == l  # Avoid division by zero
    ((c - l) - (h - c)) / (h - l)
  end

  # Calculate money flow volume
  mf_volume = mf_multiplier.zip(volume).map { |m, v| m * v }

  # Calculate CMF using rolling window
  result = Array.new(close.length, nil)

  (period - 1...close.length).each do |i|
    start_idx = i - period + 1
    period_mf_volume = mf_volume[start_idx..i].sum
    period_volume = volume[start_idx..i].sum

    result[i] = period_volume.zero? ? 0 : period_mf_volume / period_volume
  end

  result
end

# Usage
high = [...]
low = [...]
close = [...]
volume = [...]

cmf = calculate_cmf(high, low, close, volume, period: 20)
puts "CMF(20): #{cmf.last.round(4)}"

if cmf.last > 0
  puts "Buying pressure dominant"
elsif cmf.last < 0
  puts "Selling pressure dominant"
end
```

## Interpretation

### Signal Ranges

| CMF Value | Interpretation | Action |
|-----------|----------------|--------|
| **+0.25 to +1.0** | Strong buying pressure | Confirm uptrend, hold longs |
| **+0.05 to +0.25** | Moderate buying pressure | Cautiously bullish |
| **-0.05 to +0.05** | Neutral | No clear edge |
| **-0.25 to -0.05** | Moderate selling pressure | Cautiously bearish |
| **-1.0 to -0.25** | Strong selling pressure | Confirm downtrend, hold shorts |

### Key Signals

**1. Zero Line Crosses**
```ruby
# CMF crosses above zero = Bullish
# CMF crosses below zero = Bearish

if cmf.last > 0 && cmf[-2] <= 0
  puts "CMF Cross Above Zero - BULLISH"
elsif cmf.last < 0 && cmf[-2] >= 0
  puts "CMF Cross Below Zero - BEARISH"
end
```

**2. Divergences**
```ruby
# Price makes new high, CMF makes lower high = Bearish divergence
# Price makes new low, CMF makes higher low = Bullish divergence

if close.last > close[-10..-1].max && cmf.last < cmf[-10..-1].max
  puts "Bearish Divergence - Weakening uptrend"
end
```

**3. Extreme Readings**
```ruby
# Sustained CMF > +0.25 = Very strong accumulation
# Sustained CMF < -0.25 = Very strong distribution

if cmf.last > 0.25
  puts "Strong accumulation phase"
elsif cmf.last < -0.25
  puts "Strong distribution phase"
end
```

## Comparison with Related Indicators

### CMF vs AD vs ADOSC

| Feature | CMF | AD | ADOSC |
|---------|-----|----|----|
| **Bounded** | Yes (-1 to +1) | No | No |
| **Calculation** | Fixed period average | Cumulative | MACD of AD |
| **Best For** | Comparing securities | Long-term trends | Momentum shifts |
| **Availability** | Not in TA-Lib | [Available](ad.md) | [Available](adosc.md) |

## Alternative Indicators in SQA::TAI

Since CMF is not available, use these similar indicators:

### 1. [Chaikin A/D Oscillator (ADOSC)](adosc.md)
Most similar to CMF:
```ruby
require 'sqa/tai'

# ADOSC is available and similar to CMF
adosc = SQA::TAI.adosc(high, low, close, volume,
                        fast_period: 3,
                        slow_period: 10)

puts "ADOSC: #{adosc.last.round(2)}"

if adosc.last > 0
  puts "Accumulation (similar to positive CMF)"
elsif adosc.last < 0
  puts "Distribution (similar to negative CMF)"
end
```

### 2. [Accumulation/Distribution Line (AD)](ad.md)
Underlying indicator:
```ruby
require 'sqa/tai'

ad = SQA::TAI.ad(high, low, close, volume)

# Look at AD trend
ad_trend = ad.last > ad[-5] ? "Rising" : "Falling"
puts "A/D Line: #{ad_trend}"
```

### 3. [Money Flow Index (MFI)](../momentum/mfi.md)
Volume-weighted RSI:
```ruby
require 'sqa/tai'

mfi = SQA::TAI.mfi(high, low, close, volume, period: 14)

puts "MFI: #{mfi.last.round(2)}"

if mfi.last > 80
  puts "Overbought with volume"
elsif mfi.last < 20
  puts "Oversold with volume"
end
```

### 4. [On Balance Volume (OBV)](obv.md)
Simple volume indicator:
```ruby
require 'sqa/tai'

obv = SQA::TAI.obv(close, volume)

# OBV trend
if obv.last > obv[-5]
  puts "Volume supporting price (like positive CMF)"
else
  puts "Volume not supporting price (like negative CMF)"
end
```

## Trading Strategies with CMF

### Strategy 1: Trend Confirmation

```ruby
# Confirm trends with CMF
ema_20 = SQA::TAI.ema(close, period: 20)
cmf = calculate_cmf(high, low, close, volume, 20)

# Uptrend confirmation
if close.last > ema_20.last && cmf.last > 0.1
  puts "CONFIRMED UPTREND"
  puts "Price above EMA and CMF positive"

# Downtrend confirmation
elsif close.last < ema_20.last && cmf.last < -0.1
  puts "CONFIRMED DOWNTREND"
  puts "Price below EMA and CMF negative"
end
```

### Strategy 2: Divergence Trading

```ruby
# Look for divergences between price and CMF
cmf = calculate_cmf(high, low, close, volume, 20)

# Bearish divergence
recent_high_price = close[-20..-1].max
recent_high_cmf = cmf[-20..-1].max

if close.last >= recent_high_price && cmf.last < recent_high_cmf
  puts "BEARISH DIVERGENCE"
  puts "Price new high, CMF lower high"
  puts "Consider taking profits or going short"
end

# Bullish divergence
recent_low_price = close[-20..-1].min
recent_low_cmf = cmf[-20..-1].min

if close.last <= recent_low_price && cmf.last > recent_low_cmf
  puts "BULLISH DIVERGENCE"
  puts "Price new low, CMF higher low"
  puts "Consider buying opportunity"
end
```

### Strategy 3: Breakout Validation

```ruby
# Validate breakouts with CMF
resistance = 250.0  # Key level
cmf = calculate_cmf(high, low, close, volume, 20)

if close.last > resistance
  if cmf.last > 0.15
    puts "VALID BREAKOUT"
    puts "Price above resistance with strong CMF"
    puts "High probability continuation"
  else
    puts "WEAK BREAKOUT"
    puts "Price above resistance but CMF weak"
    puts "Potential false breakout"
  end
end
```

## Complete CMF Calculator Class

```ruby
require 'sqa/tai'

class ChaikinMoneyFlow
  attr_reader :values

  def initialize(high, low, close, volume, period: 20)
    @high = high
    @low = low
    @close = close
    @volume = volume
    @period = period
    calculate
  end

  def calculate
    # Calculate money flow multiplier
    mf_multiplier = @high.zip(@low, @close).map do |h, l, c|
      next 0 if (h - l).zero?
      ((c - l) - (h - c)) / (h - l)
    end

    # Calculate money flow volume
    mf_volume = mf_multiplier.zip(@volume).map { |m, v| m * v }

    # Calculate CMF for each period
    @values = Array.new(@close.length, nil)

    (@period - 1...@close.length).each do |i|
      start_idx = i - @period + 1
      sum_mf_volume = mf_volume[start_idx..i].sum
      sum_volume = @volume[start_idx..i].sum

      @values[i] = sum_volume.zero? ? 0 : sum_mf_volume / sum_volume
    end
  end

  def last
    @values.last
  end

  def signal
    return :neutral if last.nil?

    case last
    when 0.25..Float::INFINITY
      :strong_buying
    when 0.05..0.25
      :moderate_buying
    when -0.05..0.05
      :neutral
    when -0.25..-0.05
      :moderate_selling
    when -Float::INFINITY..-0.25
      :strong_selling
    end
  end

  def trend
    return :unknown if @values.compact.length < 5

    recent = @values.compact.last(5)
    avg = recent.sum / recent.length

    if avg > 0.1
      :accumulation
    elsif avg < -0.1
      :distribution
    else
      :neutral
    end
  end

  def divergence?(price_data)
    return nil if @values.compact.length < 10

    # Check last 10 periods for divergence
    recent_prices = price_data.last(10)
    recent_cmf = @values.compact.last(10)

    price_trend = recent_prices.last > recent_prices.first ? :up : :down
    cmf_trend = recent_cmf.last > recent_cmf.first ? :up : :down

    if price_trend == :up && cmf_trend == :down
      :bearish_divergence
    elsif price_trend == :down && cmf_trend == :up
      :bullish_divergence
    else
      :no_divergence
    end
  end

  def trading_signal(price)
    sig = signal
    div = divergence?(price)

    case sig
    when :strong_buying
      if div == :bearish_divergence
        { action: :caution, reason: "Strong buying but bearish divergence" }
      else
        { action: :buy, reason: "Strong accumulation" }
      end
    when :strong_selling
      if div == :bullish_divergence
        { action: :caution, reason: "Strong selling but bullish divergence" }
      else
        { action: :sell, reason: "Strong distribution" }
      end
    when :moderate_buying
      { action: :hold_long, reason: "Moderate accumulation" }
    when :moderate_selling
      { action: :hold_short, reason: "Moderate distribution" }
    else
      { action: :wait, reason: "Neutral money flow" }
    end
  end

  def to_s
    <<~INFO
      Chaikin Money Flow (#{@period})
      Current Value: #{last.nil? ? 'N/A' : last.round(4)}
      Signal: #{signal}
      Trend: #{trend}
      Divergence: #{divergence?(@close)}
    INFO
  end
end

# Usage Example
high = [100, 102, 105, 104, 106, 108, 107, 109, 111, 110]
low = [98, 100, 103, 102, 104, 106, 105, 107, 109, 108]
close = [99, 101, 104, 103, 105, 107, 106, 108, 110, 109]
volume = [1000, 1500, 2000, 1200, 1800, 2200, 1400, 1900, 2500, 1600]

cmf = ChaikinMoneyFlow.new(high, low, close, volume, period: 5)
puts cmf.to_s

signal = cmf.trading_signal(close)
puts "\nTrading Signal:"
puts "  Action: #{signal[:action]}"
puts "  Reason: #{signal[:reason]}"
```

## Best Practices

### 1. Use with Trend Indicators

```ruby
# Combine CMF with moving averages
cmf = ChaikinMoneyFlow.new(high, low, close, volume, period: 20)
ema_50 = SQA::TAI.ema(close, period: 50)

# Only take signals aligned with trend
if close.last > ema_50.last && cmf.last > 0
  puts "Aligned bullish signals"
end
```

### 2. Multiple Timeframe Confirmation

```ruby
# Use CMF on different timeframes
daily_cmf = ChaikinMoneyFlow.new(daily_high, daily_low, daily_close,
                                  daily_volume, period: 20)
hourly_cmf = ChaikinMoneyFlow.new(hourly_high, hourly_low, hourly_close,
                                   hourly_volume, period: 20)

# Both timeframes aligned
if daily_cmf.last > 0 && hourly_cmf.last > 0
  puts "Multi-timeframe accumulation confirmed"
end
```

### 3. Combine with Other Volume Indicators

```ruby
# Use multiple volume indicators for confirmation
cmf = ChaikinMoneyFlow.new(high, low, close, volume, period: 20)
obv = SQA::TAI.obv(close, volume)
mfi = SQA::TAI.mfi(high, low, close, volume, period: 14)

# All volume indicators aligned
if cmf.last > 0 && obv.last > obv[-5] && mfi.last > 50
  puts "Strong volume confirmation of uptrend"
end
```

## Limitations

1. **Lagging Indicator**: CMF uses historical data and may lag price action
2. **False Signals**: Can give false signals in choppy, low-volume markets
3. **Period Sensitivity**: Different periods can give conflicting signals
4. **Volume Quality**: Accuracy depends on reliable volume data

## See Also

### Related Volume Indicators
- [Accumulation/Distribution (AD)](ad.md) - Cumulative volume indicator
- [Chaikin A/D Oscillator (ADOSC)](adosc.md) - Similar momentum indicator
- [On Balance Volume (OBV)](obv.md) - Simple volume flow indicator
- [Money Flow Index (MFI)](../momentum/mfi.md) - Volume-weighted RSI

### Recommended Combinations
- [EMA](../overlap/ema.md) - Trend direction
- [RSI](../momentum/rsi.md) - Momentum confirmation
- [MACD](../momentum/macd.md) - Trend strength
- [Bollinger Bands](../overlap/bbands.md) - Volatility context

## Resources

- [Investopedia: Chaikin Money Flow](https://www.investopedia.com/terms/c/chaikinmoneyflow.asp)
- [StockCharts: CMF](https://school.stockcharts.com/doku.php?id=technical_indicators:chaikin_money_flow)
- [Volume Indicators Overview](index.md)

---

**Implementation Status**: Not available in current TA-Lib/SQA::TAI version. Use manual calculation or [ADOSC](adosc.md) as alternative. The provided Ruby implementation can be used for custom CMF calculations.
