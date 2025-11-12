# Engulfing Pattern

The Engulfing pattern is a powerful two-candlestick reversal pattern. A bullish engulfing occurs when a large white candle completely engulfs the previous small black candle. A bearish engulfing is the opposite.

## Usage

```ruby
require 'sqa/tai'

open  = [100.0, 101.0, 102.0, 104.0, 103.0]
high  = [101.0, 102.5, 105.0, 105.0, 108.0]
low   = [99.0, 100.5, 101.5, 102.5, 102.0]
close = [100.5, 102.0, 104.5, 103.0, 107.0]

# Detect Engulfing patterns
engulfing = SQA::TAI.cdl_engulfing(open, high, low, close)

if engulfing.last == 100
  puts "Bullish Engulfing - Buy signal!"
elsif engulfing.last == -100
  puts "Bearish Engulfing - Sell signal!"
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
- **0**: No Engulfing pattern
- **100**: Bullish Engulfing (buy signal)
- **-100**: Bearish Engulfing (sell signal)

## Bullish Engulfing

### Characteristics
- Occurs after downtrend
- First candle: Small bearish (black)
- Second candle: Large bullish (white)
- Second candle engulfs first

### Visual Pattern
```
After downtrend:

  |---|      Small bearish

    |-----|  Large bullish (engulfs previous)
    |     |
    |-----|
```

## Bearish Engulfing

### Characteristics
- Occurs after uptrend
- First candle: Small bullish (white)
- Second candle: Large bearish (black)
- Second candle engulfs first

### Visual Pattern
```
After uptrend:

  |-----|    Small bullish

    |-----|  Large bearish (engulfs previous)
    |     |
    |-----|
```

## Interpretation

- **Strong reversal signal**: One of most reliable patterns
- Shows momentum shift
- Large candle shows conviction
- Best at key support/resistance levels

## Example: Engulfing in Trend Context

```ruby
open, high, low, close = load_ohlc_data('AAPL')

engulfing = SQA::TAI.cdl_engulfing(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)

if engulfing.last == 100
  # Bullish engulfing
  in_downtrend = close[-2] < sma_50[-2]

  if in_downtrend
    puts "Bullish Engulfing in downtrend!"
    puts "Strong reversal signal - Consider LONG"
  else
    puts "Bullish Engulfing but not in downtrend"
    puts "May be continuation - verify context"
  end
elsif engulfing.last == -100
  # Bearish engulfing
  in_uptrend = close[-2] > sma_50[-2]

  if in_uptrend
    puts "Bearish Engulfing in uptrend!"
    puts "Strong reversal signal - Consider SHORT"
  else
    puts "Bearish Engulfing but not in uptrend"
    puts "May be continuation - verify context"
  end
end
```

## Example: Engulfing with Volume Confirmation

```ruby
open, high, low, close, volume = load_ohlc_volume_data('TSLA')

engulfing = SQA::TAI.cdl_engulfing(open, high, low, close)

if engulfing.last != 0
  pattern_type = engulfing.last > 0 ? "Bullish" : "Bearish"

  # Compare volumes
  vol_first_candle = volume[-2]
  vol_engulfing_candle = volume[-1]
  avg_volume = volume[-20..-1].sum / 20.0

  puts "#{pattern_type} Engulfing Pattern"
  puts "First candle volume: #{vol_first_candle.round(0)}"
  puts "Engulfing candle volume: #{vol_engulfing_candle.round(0)}"
  puts "Average volume: #{avg_volume.round(0)}"

  # Strong pattern = engulfing candle has high volume
  if vol_engulfing_candle > avg_volume * 1.5
    puts "\nSTRONG PATTERN with high volume!"
    puts "High conviction reversal"
  elsif vol_engulfing_candle > vol_first_candle
    puts "\nGOOD PATTERN - volume increased"
  else
    puts "\nWEAK PATTERN - low volume"
    puts "Less reliable - wait for confirmation"
  end
end
```

## Example: Engulfing at Support/Resistance

```ruby
open, high, low, close = load_ohlc_data('MSFT')

engulfing = SQA::TAI.cdl_engulfing(open, high, low, close)

# Find key levels
resistance = close[-120..-1].max
support = close[-120..-1].min

if engulfing.last == 100  # Bullish
  distance_from_support = ((close.last - support) / support * 100).abs

  if distance_from_support < 3  # Within 3% of support
    puts "Bullish Engulfing AT SUPPORT!"
    puts "Current: #{close.last.round(2)}"
    puts "Support: #{support.round(2)}"
    puts "Buyers defending major support"
    puts "HIGH PROBABILITY reversal setup"
  end
elsif engulfing.last == -100  # Bearish
  distance_from_resistance = ((close.last - resistance) / resistance * 100).abs

  if distance_from_resistance < 3  # Within 3% of resistance
    puts "Bearish Engulfing AT RESISTANCE!"
    puts "Current: #{close.last.round(2)}"
    puts "Resistance: #{resistance.round(2)}"
    puts "Sellers defending major resistance"
    puts "HIGH PROBABILITY reversal setup"
  end
end
```

## Example: Engulfing with RSI

```ruby
open, high, low, close = load_ohlc_data('NVDA')

engulfing = SQA::TAI.cdl_engulfing(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)

if engulfing.last == 100  # Bullish
  if rsi.last < 30
    puts "Bullish Engulfing + OVERSOLD RSI!"
    puts "RSI: #{rsi.last.round(2)}"
    puts "Multiple bullish signals - Strong BUY"
  elsif rsi.last < 40
    puts "Bullish Engulfing + Low RSI"
    puts "RSI: #{rsi.last.round(2)}"
    puts "Good reversal setup"
  end
elsif engulfing.last == -100  # Bearish
  if rsi.last > 70
    puts "Bearish Engulfing + OVERBOUGHT RSI!"
    puts "RSI: #{rsi.last.round(2)}"
    puts "Multiple bearish signals - Strong SELL"
  elsif rsi.last > 60
    puts "Bearish Engulfing + High RSI"
    puts "RSI: #{rsi.last.round(2)}"
    puts "Good reversal setup"
  end
end
```

## Trading the Engulfing Pattern

### Entry Strategies

#### Aggressive Entry
```ruby
# Enter immediately at engulfing candle close
if engulfing.last != 0
  entry = close.last
  direction = engulfing.last > 0 ? "LONG" : "SHORT"
  puts "Enter #{direction} at #{entry.round(2)}"
end
```

#### Conservative Entry
```ruby
# Wait for next candle confirmation
if engulfing[-2] != 0
  if engulfing[-2] == 100 && close[-1] > close[-2]
    puts "Bullish engulfing confirmed - Enter LONG"
  elsif engulfing[-2] == -100 && close[-1] < close[-2]
    puts "Bearish engulfing confirmed - Enter SHORT"
  end
end
```

### Stop Loss Placement

```ruby
if engulfing.last == 100  # Bullish
  # Stop below engulfing pattern low
  stop = [low[-2], low[-1]].min
  stop_with_buffer = stop * 0.995  # 0.5% buffer
  puts "Stop loss: #{stop_with_buffer.round(2)}"

elsif engulfing.last == -100  # Bearish
  # Stop above engulfing pattern high
  stop = [high[-2], high[-1]].max
  stop_with_buffer = stop * 1.005  # 0.5% buffer
  puts "Stop loss: #{stop_with_buffer.round(2)}"
end
```

### Profit Targets

```ruby
if engulfing.last == 100  # Bullish
  entry = close.last
  stop = [low[-2], low[-1]].min
  risk = entry - stop

  target_1 = entry + (risk * 1.5)  # 1.5:1
  target_2 = entry + (risk * 2.5)  # 2.5:1
  target_3 = entry + (risk * 4)    # 4:1

  puts "Targets:"
  puts "T1 (1.5:1): #{target_1.round(2)}"
  puts "T2 (2.5:1): #{target_2.round(2)}"
  puts "T3 (4:1): #{target_3.round(2)}"
end
```

## Example: Complete Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('GOOGL')

engulfing = SQA::TAI.cdl_engulfing(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if engulfing.last != 0
  is_bullish = engulfing.last > 0
  pattern_name = is_bullish ? "Bullish Engulfing" : "Bearish Engulfing"

  # Context analysis
  trend = if is_bullish
    close[-2] < sma_50[-2] ? "Downtrend" : "Not downtrend"
  else
    close[-2] > sma_50[-2] ? "Uptrend" : "Not uptrend"
  end

  # RSI check
  rsi_val = rsi.last
  rsi_favorable = is_bullish ? rsi_val < 40 : rsi_val > 60

  # Volume check
  avg_vol = volume[-20..-1].sum / 20.0
  high_volume = volume.last > avg_vol * 1.3

  # Support/Resistance check
  support = close[-60..-1].min
  resistance = close[-60..-1].max
  at_key_level = if is_bullish
    (close.last - support).abs < support * 0.03
  else
    (close.last - resistance).abs < resistance * 0.03
  end

  # Size of engulfing candle
  first_body = (close[-2] - open[-2]).abs
  engulf_body = (close[-1] - open[-1]).abs
  strong_engulf = engulf_body > first_body * 2

  # Calculate score
  score = 0
  score += 1 if trend.include?("trend")
  score += 1 if rsi_favorable
  score += 1 if high_volume
  score += 1 if at_key_level
  score += 1 if strong_engulf

  puts "#{pattern_name} Pattern Analysis"
  puts "=" * 40
  puts "Trend Context: #{trend}"
  puts "RSI: #{rsi_val.round(2)} (favorable: #{rsi_favorable})"
  puts "Volume: #{high_volume ? 'High' : 'Normal'}"
  puts "At Key Level: #{at_key_level}"
  puts "Strong Engulfing: #{strong_engulf}"
  puts "\nSetup Score: #{score}/5"

  if score >= 4
    entry = close.last
    stop = is_bullish ? [low[-2], low[-1]].min : [high[-2], high[-1]].max
    stop = is_bullish ? stop * 0.995 : stop * 1.005
    risk = (entry - stop).abs
    target = is_bullish ? entry + risk * 3 : entry - risk * 3

    puts "\n*** HIGH PROBABILITY SETUP ***"
    puts "Direction: #{is_bullish ? 'LONG' : 'SHORT'}"
    puts "Entry: #{entry.round(2)}"
    puts "Stop: #{stop.round(2)}"
    puts "Target: #{target.round(2)}"
    puts "Risk: $#{risk.round(2)}"
    puts "Reward: $#{((target - entry).abs).round(2)}"
    puts "R:R = 1:3"
  elsif score >= 3
    puts "\nDECENT SETUP - Consider position sizing down"
  else
    puts "\nLOW PROBABILITY - Skip this trade"
  end
end
```

## Pattern Strength Factors

| Factor | Weak | Medium | Strong |
|--------|------|--------|--------|
| Engulfing Size | 1.2× first | 1.5× first | 2×+ first |
| Volume | < Average | Average | 1.5×+ avg |
| Trend Context | Weak trend | Clear trend | Strong trend |
| RSI | Neutral | Approaching | Extreme |
| Location | Random | Near level | At key level |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Advantages

- Clear visual pattern
- Strong reversal signal
- Objective entry/stop rules
- Works on all timeframes
- High reliability when confirmed

## Limitations

- Can occur mid-trend (false signals)
- Needs trend context
- Better with confirmation
- Requires volume analysis
- Not common (wait for quality setups)

## Common Mistakes

1. **Trading without trend context**
2. **Ignoring volume**
3. **Not using key levels**
4. **No confirmation wait**
5. **Poor stop placement**

## Best Practices

1. ✅ Wait for right trend context
2. ✅ Confirm with volume
3. ✅ Look for RSI extremes
4. ✅ Trade at support/resistance
5. ✅ Use proper risk management

## See Also

- [Hammer Pattern](cdl_hammer.md) - Single candle reversal
- [Doji Pattern](cdl_doji.md) - Indecision pattern
- [Pattern Recognition Overview](../index.md)
- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
