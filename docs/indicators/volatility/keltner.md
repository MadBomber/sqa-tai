# Keltner Channels

> **Note**: Keltner Channels are not a standard TA-Lib indicator and are not currently available in SQA::TAI. This page is provided for reference purposes as Keltner Channels are commonly used alongside other technical indicators like Bollinger Bands.

## Overview

Keltner Channels are volatility-based envelopes set above and below an exponential moving average (EMA). Unlike Bollinger Bands which use standard deviation, Keltner Channels use Average True Range (ATR) to set channel distance, making them smoother and more adaptive to actual market volatility.

## What are Keltner Channels?

Developed by Chester Keltner in the 1960s and refined by Linda Bradford Raschke in the 1980s, Keltner Channels consist of three lines:
- **Middle Line**: 20-period EMA of typical price
- **Upper Channel**: EMA + (2 × ATR)
- **Lower Channel**: EMA - (2 × ATR)

### Formula

```
Typical Price = (High + Low + Close) / 3
Middle Line = EMA(Typical Price, 20)
Upper Channel = Middle Line + (Multiplier × ATR(14))
Lower Channel = Middle Line - (Multiplier × ATR(14))

Default Multiplier = 2
```

## Typical Usage

**Note**: Array elements should be ordered from oldest to newest (chronological order)

If Keltner Channels were available, they would be used like this:

```ruby
# Hypothetical usage (NOT currently available in SQA::TAI)
require 'sqa/tai'

# Note: This functionality is not implemented
# upper, middle, lower = SQA::TAI.keltner_channels(high, low, close,
#                                                    ema_period: 20,
#                                                    atr_period: 14,
#                                                    multiplier: 2)

# Manual calculation approach using available SQA::TAI indicators:
typical_price = SQA::TAI.typprice(high, low, close)
middle_line = SQA::TAI.ema(typical_price, period: 20)
atr = SQA::TAI.atr(high, low, close, period: 14)

multiplier = 2.0
upper_channel = middle_line.zip(atr).map { |m, a| m + (multiplier * a) }
lower_channel = middle_line.zip(atr).map { |m, a| m - (multiplier * a) }

puts "Keltner Channels:"
puts "Upper: $#{upper_channel.last.round(2)}"
puts "Middle: $#{middle_line.last.round(2)}"
puts "Lower: $#{lower_channel.last.round(2)}"
puts "Price: $#{close.last.round(2)}"
```

## Interpretation

### Price Position

- **Price > Upper Channel**: Overbought condition
  - Strong uptrend
  - Potential exhaustion
  - Consider taking profits

- **Price < Lower Channel**: Oversold condition
  - Strong downtrend
  - Potential reversal
  - Look for buying opportunities

- **Price within Channels**: Normal trading range
  - Market in equilibrium
  - Wait for breakout
  - Use for mean reversion

### Channel Width

- **Widening Channels**: Increasing volatility
  - Strong trends forming
  - Breakout opportunities
  - Use wider stops

- **Narrowing Channels**: Decreasing volatility
  - Consolidation phase
  - Breakout imminent
  - Tighten stops

## Keltner Channels vs Bollinger Bands

| Feature | Keltner Channels | Bollinger Bands |
|---------|------------------|-----------------|
| **Calculation** | ATR-based | Standard deviation |
| **Smoothness** | Smoother | More reactive |
| **Volatility Measure** | Actual price range | Statistical volatility |
| **False Signals** | Fewer | More |
| **Trend Following** | Better | Good |
| **Mean Reversion** | Good | Better |

### When to Use Each

**Use Keltner Channels when:**
- You want cleaner signals
- Trading trending markets
- Need consistent channel width
- Following price action

**Use [Bollinger Bands](../overlap/bbands.md) when:**
- You want more responsive signals
- Trading ranging markets
- Need volatility-based analysis
- Looking for squeeze patterns

## Common Trading Strategies

### 1. Trend Following Strategy

```ruby
# Manual Keltner Channel calculation
typical = SQA::TAI.typprice(high, low, close)
middle = SQA::TAI.ema(typical, period: 20)
atr = SQA::TAI.atr(high, low, close, period: 14)

multiplier = 2.0
upper = middle.zip(atr).map { |m, a| m + (multiplier * a) }
lower = middle.zip(atr).map { |m, a| m - (multiplier * a) }

# Trend following rules
if close.last > upper.last
  puts "STRONG UPTREND - Hold longs or add on pullbacks"
elsif close.last < lower.last
  puts "STRONG DOWNTREND - Hold shorts or add on rallies"
else
  puts "NEUTRAL - Wait for trend signal"
end
```

### 2. Breakout Strategy

```ruby
# Detect channel breakouts
typical = SQA::TAI.typprice(high, low, close)
middle = SQA::TAI.ema(typical, period: 20)
atr = SQA::TAI.atr(high, low, close, period: 14)

upper = middle.zip(atr).map { |m, a| m + (2.0 * a) }
lower = middle.zip(atr).map { |m, a| m - (2.0 * a) }

# Previous vs current position
prev_above_upper = close[-2] > upper[-2]
curr_above_upper = close.last > upper.last

prev_below_lower = close[-2] < lower[-2]
curr_below_lower = close.last < lower.last

if !prev_above_upper && curr_above_upper
  puts "BREAKOUT ABOVE - Enter LONG"
  puts "Stop: Below middle line at $#{middle.last.round(2)}"
elsif !prev_below_lower && curr_below_lower
  puts "BREAKOUT BELOW - Enter SHORT"
  puts "Stop: Above middle line at $#{middle.last.round(2)}"
end
```

### 3. Mean Reversion Strategy

```ruby
# Buy oversold, sell overbought within channels
typical = SQA::TAI.typprice(high, low, close)
middle = SQA::TAI.ema(typical, period: 20)
atr = SQA::TAI.atr(high, low, close, period: 14)
rsi = SQA::TAI.rsi(close, period: 14)

upper = middle.zip(atr).map { |m, a| m + (2.0 * a) }
lower = middle.zip(atr).map { |m, a| m - (2.0 * a) }

# Mean reversion at extremes
if close.last < lower.last && rsi.last < 30
  puts "OVERSOLD at lower channel - BUY signal"
  puts "Target: Middle line at $#{middle.last.round(2)}"
elsif close.last > upper.last && rsi.last > 70
  puts "OVERBOUGHT at upper channel - SELL signal"
  puts "Target: Middle line at $#{middle.last.round(2)}"
end
```

### 4. Squeeze Strategy

```ruby
# Detect volatility squeeze (narrow channels)
typical = SQA::TAI.typprice(high, low, close)
middle = SQA::TAI.ema(typical, period: 20)
atr = SQA::TAI.atr(high, low, close, period: 14)

upper = middle.zip(atr).map { |m, a| m + (2.0 * a) }
lower = middle.zip(atr).map { |m, a| m - (2.0 * a) }

# Calculate channel width
channel_width = upper.zip(lower).map { |u, l| u - l }
avg_width = channel_width[-20..-1].sum / 20.0

current_width = channel_width.last
width_ratio = current_width / avg_width

puts "Channel Width Analysis:"
puts "Current: $#{current_width.round(2)}"
puts "Average: $#{avg_width.round(2)}"
puts "Ratio: #{width_ratio.round(2)}x"

if width_ratio < 0.7
  puts "\nSQUEEZE DETECTED - Low volatility"
  puts "Expect breakout soon"
  puts "Prepare for large move"
elsif width_ratio > 1.3
  puts "\nEXPANSION - High volatility"
  puts "Strong trend in progress"
  puts "Trail stops, ride the trend"
end
```

## Complete Keltner Channel Calculator

Here's a full Ruby implementation:

```ruby
class KeltnerChannels
  attr_reader :upper, :middle, :lower

  def initialize(high, low, close, ema_period: 20, atr_period: 14, multiplier: 2.0)
    @high = high
    @low = low
    @close = close
    @ema_period = ema_period
    @atr_period = atr_period
    @multiplier = multiplier

    calculate
  end

  def calculate
    # Use SQA::TAI for calculations
    typical = SQA::TAI.typprice(@high, @low, @close)
    @middle = SQA::TAI.ema(typical, period: @ema_period)
    atr = SQA::TAI.atr(@high, @low, @close, period: @atr_period)

    # Calculate channels
    @upper = @middle.zip(atr).map { |m, a| m + (@multiplier * a) }
    @lower = @middle.zip(atr).map { |m, a| m - (@multiplier * a) }
  end

  def current_position
    price = @close.last

    if price > @upper.last
      :above_upper
    elsif price < @lower.last
      :below_lower
    else
      :inside_channels
    end
  end

  def channel_width
    @upper.zip(@lower).map { |u, l| u - l }
  end

  def width_percentile(lookback = 100)
    widths = channel_width[-lookback..-1]
    current = widths.last
    rank = widths.count { |w| w <= current }
    (rank.to_f / widths.length * 100).round(2)
  end

  def trading_signal
    position = current_position
    rsi = SQA::TAI.rsi(@close, period: 14)

    case position
    when :above_upper
      if rsi.last > 70
        { signal: :overbought, action: :sell, strength: :strong }
      else
        { signal: :uptrend, action: :hold_long, strength: :moderate }
      end
    when :below_lower
      if rsi.last < 30
        { signal: :oversold, action: :buy, strength: :strong }
      else
        { signal: :downtrend, action: :hold_short, strength: :moderate }
      end
    else
      { signal: :neutral, action: :wait, strength: :weak }
    end
  end

  def to_s
    <<~INFO
      Keltner Channels (EMA: #{@ema_period}, ATR: #{@atr_period}, Mult: #{@multiplier})
      Upper:  $#{@upper.last.round(2)}
      Middle: $#{@middle.last.round(2)}
      Lower:  $#{@lower.last.round(2)}
      Price:  $#{@close.last.round(2)}
      Position: #{current_position}
      Width Percentile: #{width_percentile}%
    INFO
  end
end

# Usage Example
require 'sqa/tai'

high = [100, 102, 104, 103, 105, 107, 106, 108, 110, 109]
low = [98, 100, 102, 101, 103, 105, 104, 106, 108, 107]
close = [99, 101, 103, 102, 104, 106, 105, 107, 109, 108]

kc = KeltnerChannels.new(high, low, close)
puts kc.to_s

signal = kc.trading_signal
puts "\nTrading Signal:"
puts "  Action: #{signal[:action]}"
puts "  Strength: #{signal[:strength]}"
puts "  Reason: #{signal[:signal]}"
```

## Advanced Applications

### Multi-Timeframe Keltner Channels

```ruby
# Daily channels for trend
daily_kc = KeltnerChannels.new(daily_high, daily_low, daily_close)

# Hourly channels for entries
hourly_kc = KeltnerChannels.new(hourly_high, hourly_low, hourly_close)

# Trade with both aligned
if daily_kc.current_position == :above_upper &&
   hourly_kc.current_position == :above_upper
  puts "Strong uptrend across timeframes"
end
```

### Keltner Channel Squeeze

```ruby
# Compare Keltner width to Bollinger Band width
kc = KeltnerChannels.new(high, low, close)
bb_upper, bb_middle, bb_lower = SQA::TAI.bbands(close, period: 20)

kc_width = kc.channel_width.last
bb_width = bb_upper.last - bb_lower.last

if bb_width < kc_width * 0.8
  puts "BOLLINGER SQUEEZE inside Keltner"
  puts "Volatility compression - big move coming"
end
```

## Best Practices

### 1. Parameter Selection
- **Trending Markets**: Use EMA 20, ATR 14, Multiplier 2.0 (standard)
- **Volatile Markets**: Increase multiplier to 2.5 or 3.0
- **Choppy Markets**: Decrease multiplier to 1.5

### 2. Combine with Trend Indicators
```ruby
# Use with EMA for trend confirmation
ema_50 = SQA::TAI.ema(close, period: 50)
kc = KeltnerChannels.new(high, low, close)

# Only take signals aligned with larger trend
if close.last > ema_50.last && kc.current_position == :above_upper
  puts "Confirmed strong uptrend"
end
```

### 3. Volume Confirmation
```ruby
# Breakouts should have volume support
obv = SQA::TAI.obv(close, volume)

if close.last > kc.upper.last && obv.last > obv[-5]
  puts "Volume-confirmed breakout"
end
```

## See Also

### Similar Volatility Indicators

- [Bollinger Bands (BBANDS)](../overlap/bbands.md) - Standard deviation based bands
- [Average True Range (ATR)](atr.md) - Volatility measurement used in Keltner
- [MESA Adaptive Moving Average (MAMA)](mama.md) - Adaptive moving average
- [Overlap Studies](../overlap/index.md) - Moving averages and bands

### Recommended Combinations

- [RSI](../momentum/rsi.md) - Confirm overbought/oversold
- [MACD](../momentum/macd.md) - Trend direction and momentum
- [Volume Indicators](../volume/index.md) - Validate breakouts
- [EMA](../overlap/ema.md) - Trend filter

## Resources

- [Investopedia: Keltner Channels](https://www.investopedia.com/terms/k/keltnerchannel.asp)
- [Bollinger Bands Comparison](../overlap/bbands.md)
- [ATR Indicator](atr.md)

---

**Implementation Status**: Not available in current TA-Lib/SQA::TAI version. Use manual calculation with [ATR](atr.md), [EMA](../overlap/ema.md), and [Typical Price](../price_transform/typprice.md).
