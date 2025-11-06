# Candlestick Pattern Recognition

TA-Lib provides 60+ candlestick pattern recognition functions that identify common Japanese candlestick patterns. These patterns can signal potential reversals or continuations in price trends.

## Overview

Candlestick patterns are formed by one or more candlesticks and can indicate:
- Potential trend reversals
- Trend continuation signals
- Market indecision
- Bullish or bearish sentiment

## Using Pattern Recognition

All pattern functions follow the same API:

```ruby
require 'sqa/tai'

# OHLC data required
open   = [100.0, 101.0, 102.0, 101.5, 103.0]
high   = [102.0, 103.0, 104.0, 103.0, 105.0]
low    = [99.5, 100.0, 101.0, 100.5, 102.0]
close  = [101.0, 102.0, 101.5, 103.0, 104.0]

# Detect patterns
doji = SQA::TAI.cdl_doji(open, high, low, close)
hammer = SQA::TAI.cdl_hammer(open, high, low, close)
engulfing = SQA::TAI.cdl_engulfing(open, high, low, close)
```

## Return Values

Pattern functions return an array of integers:
- **0**: No pattern detected
- **+100**: Bullish pattern
- **-100**: Bearish pattern
- Some functions may return **+200/-200** for stronger patterns

## Featured Patterns

### Single Candlestick Patterns

- [Doji](doji.md) - Indecision, potential reversal
- [Hammer](hammer.md) - Bullish reversal after downtrend
- Shooting Star - Bearish reversal after uptrend
- Spinning Top - Indecision, small body

### Two Candlestick Patterns

- [Engulfing Pattern](engulfing.md) - Strong reversal signal
- Harami - Potential trend change
- Piercing Pattern - Bullish reversal
- Dark Cloud Cover - Bearish reversal

### Three Candlestick Patterns

- Morning Star - Bullish reversal
- Evening Star - Bearish reversal
- Three White Soldiers - Strong bullish continuation
- Three Black Crows - Strong bearish continuation

## Example: Scanning for Multiple Patterns

```ruby
open, high, low, close = load_ohlc_data('AAPL')

# Check multiple patterns
patterns = {
  'Doji' => SQA::TAI.cdl_doji(open, high, low, close),
  'Hammer' => SQA::TAI.cdl_hammer(open, high, low, close),
  'Shooting Star' => SQA::TAI.cdl_shooting_star(open, high, low, close),
  'Engulfing' => SQA::TAI.cdl_engulfing(open, high, low, close),
  'Morning Star' => SQA::TAI.cdl_morning_star(open, high, low, close),
  'Evening Star' => SQA::TAI.cdl_evening_star(open, high, low, close),
  'Harami' => SQA::TAI.cdl_harami(open, high, low, close)
}

# Check current bar for patterns
patterns.each do |name, values|
  signal = values.last
  next if signal == 0

  sentiment = signal > 0 ? "Bullish" : "Bearish"
  puts "#{name}: #{sentiment} (#{signal})"
end
```

## Example: Pattern with Trend Filter

```ruby
open, high, low, close = load_ohlc_data('TSLA')

# Calculate trend
sma_50 = SQA::TAI.sma(close, period: 50)
uptrend = close.last > sma_50.last

# Detect patterns
hammer = SQA::TAI.cdl_hammer(open, high, low, close)
shooting_star = SQA::TAI.cdl_shooting_star(open, high, low, close)

# Only take reversal signals aligned with trend context
if hammer.last == 100 && !uptrend
  puts "Hammer in downtrend - Strong bullish reversal signal!"
  puts "Consider buying"
elsif shooting_star.last == -100 && uptrend
  puts "Shooting Star in uptrend - Strong bearish reversal signal!"
  puts "Consider selling"
end
```

## Example: Pattern Confirmation with Volume

```ruby
open, high, low, close, volume = load_ohlc_volume_data('MSFT')

engulfing = SQA::TAI.cdl_engulfing(open, high, low, close)

# Calculate average volume
avg_volume = volume[-20..-1].sum / 20.0

# Pattern detected?
if engulfing.last != 0
  pattern_type = engulfing.last > 0 ? "Bullish" : "Bearish"

  # Confirm with volume
  if volume.last > avg_volume * 1.5
    puts "#{pattern_type} Engulfing with high volume!"
    puts "Volume: #{volume.last.round(0)} (avg: #{avg_volume.round(0)})"
    puts "Strong confirmation - high probability setup"
  else
    puts "#{pattern_type} Engulfing but volume low"
    puts "Weaker signal - wait for confirmation"
  end
end
```

## Pattern Categories

### Reversal Patterns

Indicate potential trend changes:
- Hammer, Hanging Man
- Engulfing Patterns
- Morning Star, Evening Star
- Piercing Pattern, Dark Cloud Cover

### Continuation Patterns

Suggest trend will continue:
- Three White Soldiers
- Three Black Crows
- Rising Three Methods
- Falling Three Methods

### Indecision Patterns

Show market uncertainty:
- Doji
- Spinning Top
- Harami
- High Wave

## Best Practices

### 1. Use Trend Context

```ruby
# Bullish patterns work best at support in uptrends
# Bearish patterns work best at resistance in downtrends
```

### 2. Confirm with Volume

```ruby
# Patterns on high volume are more reliable
if pattern_detected && volume > avg_volume * 1.5
  # Higher probability trade
end
```

### 3. Wait for Confirmation

```ruby
# Don't trade on pattern alone
# Wait for next bar to confirm direction
```

### 4. Combine Multiple Signals

```ruby
# Pattern + RSI + Support/Resistance
# Multiple confirmations = higher probability
```

## Example: Complete Pattern Analysis System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('NVDA')

# Trend context
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)
trend = if close.last > sma_50.last && sma_50.last > sma_200.last
  "Uptrend"
elsif close.last < sma_50.last && sma_50.last < sma_200.last
  "Downtrend"
else
  "Sideways"
end

# Momentum
rsi = SQA::TAI.rsi(close, period: 14)

# Volume
avg_volume = volume[-20..-1].sum / 20.0
volume_ratio = volume.last / avg_volume

# Patterns to check
patterns_to_check = {
  'Hammer' => { func: :cdl_hammer, bullish: true },
  'Shooting Star' => { func: :cdl_shooting_star, bullish: false },
  'Engulfing' => { func: :cdl_engulfing, bullish: nil },  # Can be either
  'Morning Star' => { func: :cdl_morning_star, bullish: true },
  'Evening Star' => { func: :cdl_evening_star, bullish: false }
}

puts "Market Context:"
puts "Trend: #{trend}"
puts "RSI: #{rsi.last.round(2)}"
puts "Volume Ratio: #{volume_ratio.round(2)}x"
puts "\nPattern Analysis:"

patterns_to_check.each do |name, config|
  result = SQA::TAI.send(config[:func], open, high, low, close)
  signal = result.last

  next if signal == 0

  is_bullish = signal > 0

  # Score the setup
  score = 0
  score += 1 if volume_ratio > 1.5  # High volume
  score += 1 if trend == "Uptrend" && is_bullish  # Aligned with trend
  score += 1 if trend == "Downtrend" && !is_bullish
  score += 1 if is_bullish && rsi.last < 40  # RSI not overbought
  score += 1 if !is_bullish && rsi.last > 60  # RSI not oversold

  puts "\n#{name}: #{is_bullish ? 'Bullish' : 'Bearish'}"
  puts "Setup Score: #{score}/5"

  if score >= 4
    puts "HIGH PROBABILITY SETUP!"
  elsif score >= 3
    puts "Decent setup, monitor closely"
  else
    puts "Weak setup, low probability"
  end
end
```

## Common Patterns Quick Reference

| Pattern | Candles | Signal | Reliability |
|---------|---------|--------|-------------|
| Doji | 1 | Reversal | Medium |
| Hammer | 1 | Bullish | High |
| Shooting Star | 1 | Bearish | High |
| Engulfing | 2 | Strong Reversal | High |
| Harami | 2 | Reversal | Medium |
| Morning Star | 3 | Bullish | High |
| Evening Star | 3 | Bearish | High |
| Three White Soldiers | 3 | Bullish | High |
| Three Black Crows | 3 | Bearish | High |

## See Also

- [Doji Pattern](doji.md)
- [Hammer Pattern](hammer.md)
- [Engulfing Pattern](engulfing.md)
- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
