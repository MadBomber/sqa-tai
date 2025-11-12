# Hammer Pattern

The Hammer is a bullish reversal candlestick pattern that forms during a downtrend. It has a small body near the high with a long lower shadow, resembling a hammer.

## Usage

```ruby
require 'sqa/tai'

open  = [100.0, 99.0, 98.0, 96.0, 94.0]
high  = [100.5, 99.5, 98.5, 96.5, 95.0]
low   = [98.0, 97.0, 95.0, 92.0, 90.0]
close = [99.0, 98.0, 96.0, 94.5, 94.5]

# Detect Hammer patterns
hammer = SQA::TAI.cdl_hammer(open, high, low, close)

if hammer.last == 100
  puts "Hammer detected - Bullish reversal signal!"
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
- **0**: No Hammer pattern
- **100**: Bullish Hammer detected

## Pattern Characteristics

- **Small body**: At upper end of trading range
- **Long lower shadow**: At least 2× body length
- **Little/no upper shadow**: Close near high
- **Forms in downtrend**: Reversal signal

## Visual Pattern

```
  -----  (small body near top)
    |
    |
    |
    |
    |    (long lower shadow)
```

## Interpretation

- **After downtrend**: Bullish reversal signal
- Shows rejection of lower prices
- Buyers stepping in at lower levels
- Potential bottom formation
- Best with confirmation candle

## Related Patterns

- **Inverted Hammer**: Long upper shadow (also bullish)
- **Hanging Man**: Same shape but in uptrend (bearish)
- **Dragonfly Doji**: Open/close at high (similar sentiment)

## Example: Hammer in Downtrend

```ruby
open, high, low, close = load_ohlc_data('AAPL')

hammer = SQA::TAI.cdl_hammer(open, high, low, close)
sma_20 = SQA::TAI.sma(close, period: 20)

if hammer.last == 100
  # Verify downtrend context
  in_downtrend = close[-2] < sma_20[-2] && close[-2] < close[-10]

  if in_downtrend
    puts "Hammer in downtrend - Strong reversal signal!"
    puts "Current: #{close.last.round(2)}"
    puts "Wait for bullish confirmation candle"
  else
    puts "Hammer detected but not in downtrend"
    puts "Less reliable - exercise caution"
  end
end
```

## Example: Hammer with Confirmation

```ruby
open, high, low, close = load_ohlc_data('TSLA')

hammer = SQA::TAI.cdl_hammer(open, high, low, close)

# Check previous bar for hammer
if hammer[-2] == 100
  hammer_close = close[-2]
  confirm_close = close[-1]

  # Confirmation: next candle closes above hammer body
  if confirm_close > hammer_close
    puts "Hammer CONFIRMED by bullish candle!"
    puts "Hammer close: #{hammer_close.round(2)}"
    puts "Confirmation close: #{confirm_close.round(2)}"
    puts "High probability long entry"

    # Calculate entry, stop, target
    entry = confirm_close
    stop = low[-2] - (low[-2] * 0.005)  # Below hammer low
    risk = entry - stop
    target = entry + (risk * 2)  # 2:1 reward

    puts "\nTrade Setup:"
    puts "Entry: #{entry.round(2)}"
    puts "Stop: #{stop.round(2)}"
    puts "Target: #{target.round(2)}"
    puts "Risk:Reward = 1:2"
  end
end
```

## Example: Hammer at Support

```ruby
open, high, low, close = load_ohlc_data('MSFT')

hammer = SQA::TAI.cdl_hammer(open, high, low, close)

# Find support level (recent low)
support = close[-60..-1].min

if hammer.last == 100
  # Check if hammer formed at support
  distance_from_support = ((close.last - support) / support * 100).abs

  if distance_from_support < 2  # Within 2% of support
    puts "Hammer at support level!"
    puts "Current: #{close.last.round(2)}"
    puts "Support: #{support.round(2)}"
    puts "High probability reversal zone"
    puts "Buyers defending support + hammer = strong signal"
  end
end
```

## Example: Hammer with Volume

```ruby
open, high, low, close, volume = load_ohlc_volume_data('NVDA')

hammer = SQA::TAI.cdl_hammer(open, high, low, close)

if hammer.last == 100
  avg_volume = volume[-20..-1].sum / 20.0

  if volume.last > avg_volume * 1.5
    puts "Hammer with HIGH VOLUME!"
    puts "Volume: #{volume.last.round(0)} (avg: #{avg_volume.round(0)})"
    puts "Strong buying pressure at lows"
    puts "Very bullish signal"
  elsif volume.last < avg_volume * 0.7
    puts "Hammer with low volume"
    puts "Weaker signal - less conviction"
    puts "Wait for volume confirmation"
  else
    puts "Hammer with normal volume"
    puts "Standard setup - wait for confirmation"
  end
end
```

## Example: Hammer with RSI

```ruby
open, high, low, close = load_ohlc_data('GOOGL')

hammer = SQA::TAI.cdl_hammer(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)

if hammer.last == 100
  current_rsi = rsi.last

  if current_rsi < 30
    puts "Hammer in OVERSOLD territory!"
    puts "RSI: #{current_rsi.round(2)}"
    puts "Multiple bullish signals converging"
    puts "High probability reversal"
  elsif current_rsi < 40
    puts "Hammer with RSI below 40"
    puts "RSI: #{current_rsi.round(2)}"
    puts "Good reversal setup"
  else
    puts "Hammer but RSI at #{current_rsi.round(2)}"
    puts "Not oversold - lower probability"
  end
end
```

## Trading the Hammer

### Conservative Entry (Recommended)

```ruby
# Wait for confirmation candle
if hammer[-2] == 100 && close[-1] > close[-2]
  entry = close[-1]
  stop = low[-2]
  puts "Enter long at #{entry} with stop at #{stop}"
end
```

### Aggressive Entry

```ruby
# Enter on hammer close
if hammer.last == 100
  entry = close.last
  stop = low.last
  puts "Enter long at #{entry} with stop at #{stop}"
end
```

### Stop Loss Placement

```ruby
# Stop below hammer's low
if hammer[-2] == 100
  stop_loss = low[-2] - (low[-2] * 0.005)  # 0.5% buffer
  puts "Stop loss: #{stop_loss.round(2)}"
end
```

### Target Setting

```ruby
# Use 2:1 or 3:1 reward:risk
if hammer[-2] == 100
  entry = close[-1]
  stop = low[-2]
  risk = entry - stop

  target_2to1 = entry + (risk * 2)
  target_3to1 = entry + (risk * 3)

  puts "Target (2:1): #{target_2to1.round(2)}"
  puts "Target (3:1): #{target_3to1.round(2)}"
end
```

## Example: Complete Hammer Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('AAPL')

hammer = SQA::TAI.cdl_hammer(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)

# Check previous bar
if hammer[-2] == 100
  # Context checks
  in_downtrend = close[-2] < sma_50[-2]
  oversold = rsi[-2] < 40
  confirmation = close[-1] > close[-2]

  avg_volume = volume[-20..-2].sum / 19.0
  high_volume = volume[-2] > avg_volume * 1.3

  # Support check
  recent_low = close[-60..-2].min
  at_support = (close[-2] - recent_low).abs < recent_low * 0.02

  # Calculate score
  score = 0
  score += 1 if in_downtrend
  score += 1 if oversold
  score += 1 if confirmation
  score += 1 if high_volume
  score += 1 if at_support

  puts "Hammer Pattern Analysis:"
  puts "Downtrend: #{in_downtrend ? 'Yes' : 'No'}"
  puts "Oversold RSI: #{oversold ? 'Yes' : 'No'} (#{rsi[-2].round(2)})"
  puts "Confirmation: #{confirmation ? 'Yes' : 'No'}"
  puts "High Volume: #{high_volume ? 'Yes' : 'No'}"
  puts "At Support: #{at_support ? 'Yes' : 'No'}"
  puts "\nSetup Score: #{score}/5"

  if score >= 4 && confirmation
    entry = close[-1]
    stop = low[-2]
    risk = entry - stop
    target = entry + (risk * 2.5)

    puts "\n*** HIGH PROBABILITY LONG SETUP ***"
    puts "Entry: #{entry.round(2)}"
    puts "Stop: #{stop.round(2)}"
    puts "Target: #{target.round(2)}"
    puts "Risk: #{risk.round(2)} (#{((risk/entry)*100).round(2)}%)"
    puts "Reward: #{(target-entry).round(2)} (#{(((target-entry)/entry)*100).round(2)}%)"
    puts "R:R = 1:2.5"
  elsif score >= 3
    puts "\nDECENT SETUP - Monitor closely"
  else
    puts "\nLOW PROBABILITY - Skip this trade"
  end
end
```

## Hammer Quality Factors

| Factor | Good | Better | Best |
|--------|------|--------|------|
| Shadow Length | 2× body | 3× body | 4×+ body |
| Trend Context | Down | Strong down | Capitulation |
| RSI | < 50 | < 40 | < 30 |
| Volume | Average | 1.3× avg | 2×+ avg |
| Support | None | Near | At major level |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Common Mistakes

1. **Trading without confirmation**: Wait for next candle
2. **Ignoring trend context**: Need downtrend for reliability
3. **No volume confirmation**: High volume adds conviction
4. **Wrong timeframe**: Works better on daily+ charts
5. **Ignoring support levels**: Strongest at support zones

## Reliability

- **High**: After downtrend, at support, with volume, confirmed
- **Medium**: In downtrend with confirmation
- **Low**: Without downtrend context or confirmation

## See Also

- [Shooting Star](cdl_hammer.md) - Bearish opposite
- [Pattern Recognition Overview](../index.md)
- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
