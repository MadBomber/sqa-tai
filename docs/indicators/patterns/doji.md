# Doji Pattern

A Doji is a candlestick pattern that occurs when the opening and closing prices are virtually equal, creating a cross or plus sign shape. It signals indecision in the market and potential reversal.

## Usage

```ruby
require 'sqa/tai'

open  = [100.0, 101.5, 102.0, 103.5, 104.0]
high  = [101.5, 103.0, 104.0, 105.0, 105.5]
low   = [99.0, 100.5, 101.5, 102.5, 103.5]
close = [101.0, 101.5, 102.0, 103.5, 104.0]

# Detect Doji patterns
doji = SQA::TAI.cdl_doji(open, high, low, close)

if doji.last != 0
  puts "Doji detected!"
end
```

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `open` | Array | Yes | Array of opening prices |
| `high` | Array | Yes | Array of high prices |
| `low` | Array | Yes | Array of low prices |
| `close` | Array | Yes | Array of closing prices |

## Returns

Returns an array of integers:
- **0**: No Doji pattern
- **100**: Doji detected

## Pattern Characteristics

- Open and close are very close (or equal)
- Can have long upper and/or lower shadows
- Small or non-existent body
- Shows market indecision

## Visual Pattern

```
      |
      |
      |
    -----  (very small body)
      |
      |
      |
```

## Interpretation

- **After uptrend**: Potential bearish reversal
- **After downtrend**: Potential bullish reversal
- **In sideways market**: Continuation of indecision
- **At support/resistance**: Higher significance

## Types of Doji

### Standard Doji
Open = Close (or very close), shadows present

### Long-Legged Doji
Long upper and lower shadows, high volatility

### Gravestone Doji
Open/close at low, long upper shadow (bearish)

### Dragonfly Doji
Open/close at high, long lower shadow (bullish)

## Example: Doji Reversal Detection

```ruby
open, high, low, close = load_ohlc_data('AAPL')

doji = SQA::TAI.cdl_doji(open, high, low, close)
sma_20 = SQA::TAI.sma(close, period: 20)

if doji.last == 100
  # Determine trend context
  if close[-2] > sma_20[-2]
    puts "Doji after uptrend - Potential bearish reversal"
    puts "Watch for confirmation on next candle"
  elsif close[-2] < sma_20[-2]
    puts "Doji after downtrend - Potential bullish reversal"
    puts "Watch for confirmation on next candle"
  else
    puts "Doji in sideways market - Continued indecision"
  end
end
```

## Example: Doji at Key Levels

```ruby
open, high, low, close = load_ohlc_data('TSLA')

doji = SQA::TAI.cdl_doji(open, high, low, close)

# Find recent high (resistance)
resistance = close[-60..-1].max

if doji.last == 100
  # Is it at resistance?
  if (close.last - resistance).abs < resistance * 0.02  # Within 2%
    puts "Doji at resistance level!"
    puts "Current: #{close.last.round(2)}"
    puts "Resistance: #{resistance.round(2)}"
    puts "Strong reversal signal - sellers stepping in"
  end
end

# Find recent low (support)
support = close[-60..-1].min

if doji.last == 100
  # Is it at support?
  if (close.last - support).abs < support * 0.02  # Within 2%
    puts "Doji at support level!"
    puts "Current: #{close.last.round(2)}"
    puts "Support: #{support.round(2)}"
    puts "Potential bounce - buyers defending level"
  end
end
```

## Example: Doji with Volume Confirmation

```ruby
open, high, low, close, volume = load_ohlc_volume_data('MSFT')

doji = SQA::TAI.cdl_doji(open, high, low, close)

if doji.last == 100
  # Check volume
  avg_volume = volume[-20..-1].sum / 20.0

  if volume.last > avg_volume * 1.5
    puts "Doji with high volume!"
    puts "Volume: #{volume.last.round(0)} (avg: #{avg_volume.round(0)})"
    puts "Strong indecision - significant reversal potential"
  else
    puts "Doji with normal/low volume"
    puts "Less significant - may need confirmation"
  end
end
```

## Example: Doji Series (Star Pattern)

```ruby
open, high, low, close = load_ohlc_data('NVDA')

doji = SQA::TAI.cdl_doji(open, high, low, close)

# Check for Morning/Evening Star patterns that include Doji
morning_star = SQA::TAI.cdl_morning_star(open, high, low, close)
evening_star = SQA::TAI.cdl_evening_star(open, high, low, close)

if doji.last == 100
  puts "Doji detected"

  # Is it part of a star pattern?
  if morning_star.last == 100
    puts "Part of Morning Star pattern - Strong bullish reversal!"
  elsif evening_star.last == -100
    puts "Part of Evening Star pattern - Strong bearish reversal!"
  else
    puts "Standalone Doji - Monitor for confirmation"
  end
end
```

## Trading the Doji

### Entry Rules

1. **After Uptrend (Bearish)**
```ruby
# Wait for confirmation
if doji[-2] == 100 && close[-1] < open[-1]
  puts "Doji confirmed by bearish candle - SHORT"
end
```

2. **After Downtrend (Bullish)**
```ruby
# Wait for confirmation
if doji[-2] == 100 && close[-1] > open[-1]
  puts "Doji confirmed by bullish candle - LONG"
end
```

### Stop Loss

```ruby
# Place stop beyond the Doji's high/low
if doji[-2] == 100
  if close[-2] > close[-3]  # Bearish Doji
    stop_loss = high[-2] + (high[-2] * 0.01)  # 1% above high
  else  # Bullish Doji
    stop_loss = low[-2] - (low[-2] * 0.01)  # 1% below low
  end
end
```

## Example: Complete Doji Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('GOOGL')

doji = SQA::TAI.cdl_doji(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)

# Check for Doji
if doji[-2] == 100  # Check previous candle
  prev_trend = close[-3] > sma_50[-3] ? "Up" : "Down"
  confirmation = close[-1] < open[-1] ? "Bearish" : "Bullish"

  avg_volume = volume[-20..-2].sum / 19.0
  high_volume = volume[-2] > avg_volume * 1.3

  puts "Doji Pattern Analysis:"
  puts "Previous Trend: #{prev_trend}trend"
  puts "Confirmation Candle: #{confirmation}"
  puts "RSI: #{rsi[-2].round(2)}"
  puts "Volume: #{high_volume ? 'High' : 'Normal'}"

  # Bearish reversal setup
  if prev_trend == "Up" && confirmation == "Bearish" &&
     rsi[-2] > 60 && high_volume
    puts "\nHIGH PROBABILITY SHORT SETUP"
    puts "Entry: #{close[-1].round(2)}"
    puts "Stop: #{high[-2].round(2)}"
    target = close[-1] - (high[-2] - close[-1]) * 2
    puts "Target: #{target.round(2)}"
  end

  # Bullish reversal setup
  if prev_trend == "Down" && confirmation == "Bullish" &&
     rsi[-2] < 40 && high_volume
    puts "\nHIGH PROBABILITY LONG SETUP"
    puts "Entry: #{close[-1].round(2)}"
    puts "Stop: #{low[-2].round(2)}"
    target = close[-1] + (close[-1] - low[-2]) * 2
    puts "Target: #{target.round(2)}"
  end
end
```

## Key Points

- Doji shows indecision, not direction
- Context is crucial (trend, support/resistance)
- Always wait for confirmation
- More reliable with high volume
- Best at extremes (overbought/oversold)

## Reliability

- **High**: At major support/resistance with volume
- **Medium**: In clear trend with confirmation
- **Low**: In choppy/sideways market

## Related Patterns

- [Hammer](hammer.md) - Similar but with small body
- [Spinning Top](doji.md) - Small body, indecision
- Morning/Evening Star - Multi-candle patterns with Doji

## See Also

- [Pattern Recognition Overview](index.md)
- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
