# Three Inside Up/Down Pattern

The Three Inside Up/Down is a reliable three-candlestick reversal pattern that combines an engulfing pattern with a confirmation candle. The bullish variant (Three Inside Up) appears in downtrends, while the bearish variant (Three Inside Down) appears in uptrends, making them powerful trend reversal signals.

## Pattern Type

- **Type**: Reversal (both bullish and bearish variants)
- **Candles Required**: 3
- **Trend Context**: Appears at trend extremes
- **Reliability**: High (combines engulfing + confirmation)
- **Frequency**: Moderate (2-3% of the time)

## Usage

```ruby
require 'sqa/tai'

open  = [105.0, 103.0, 102.0, 103.5, 104.5]
high  = [106.0, 104.0, 104.5, 105.0, 106.0]
low   = [102.0, 101.5, 101.5, 102.5, 103.5]
close = [103.0, 102.0, 104.0, 104.5, 105.5]

# Detect Three Inside Up/Down pattern
pattern = SQA::TAI.cdl_3inside(open, high, low, close)

if pattern.last == 100
  puts "Three Inside Up detected - Bullish reversal signal!"
elsif pattern.last == -100
  puts "Three Inside Down detected - Bearish reversal signal!"
end
```

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `open` | Array<Float> | Yes | Array of opening prices |
| `high` | Array<Float> | Yes | Array of high prices |
| `low` | Array<Float> | Yes | Array of low prices |
| `close` | Array<Float> | Yes | Array of closing prices |

## Returns

Returns an array of integers:
- **0**: No Three Inside Up/Down pattern detected
- **100**: Three Inside Up pattern detected (bullish reversal signal)
- **-100**: Three Inside Down pattern detected (bearish reversal signal)

## Pattern Recognition Rules

### Three Inside Up (Bullish)

1. **First Candle**: Long bearish candle in established downtrend
2. **Second Candle**: Bullish candle that is engulfed by first candle's body (harami)
3. **Third Candle**: Bullish candle that closes above first candle's close (confirmation)

### Three Inside Down (Bearish)

1. **First Candle**: Long bullish candle in established uptrend
2. **Second Candle**: Bearish candle that is engulfed by first candle's body (harami)
3. **Third Candle**: Bearish candle that closes below first candle's close (confirmation)

### Key Characteristics

- Pattern is essentially a harami (engulfing) followed by confirmation
- Second candle opens and closes within first candle's range
- Third candle confirms direction by breaking past first candle's close
- More reliable than standalone harami due to confirmation
- "Inside" refers to second candle being inside first candle

## Visual Pattern

```
Three Inside Up (Bullish):
After downtrend:

  |=====|      First candle (long bearish)
  |     |
    |==|        Second candle (bullish, inside first)
     |===|      Third candle (bullish confirmation)
     |   |

Three Inside Down (Bearish):
After uptrend:

  |=====|      First candle (long bullish)
  |     |
    |==|        Second candle (bearish, inside first)
     |===|      Third candle (bearish confirmation)
     |   |
```

## Interpretation

The Three Inside pattern signals trend reversal through:

1. **Initial Exhaustion**: Long first candle shows trend climax
2. **Hesitation**: Second candle inside first shows momentum loss
3. **Confirmation**: Third candle confirms new direction
4. **Psychological Shift**: Pattern shows clear sentiment change
5. **Higher Reliability**: Three-candle formation reduces false signals

### Reliability Factors

| Factor | Low Reliability | Medium Reliability | High Reliability |
|--------|----------------|-------------------|------------------|
| Trend Strength | Weak trend | Clear trend | Strong trend |
| First Candle | Short body | Medium body | Long body |
| Second Candle | Near edge | Mid-range | Well-centered |
| Third Candle | Small close | Moderate close | Strong close |
| Volume | Decreasing | Normal | Increasing on 3rd |
| Location | Mid-chart | Near level | At support/resistance |

## Example: Three Inside Up in Downtrend

```ruby
open, high, low, close = load_ohlc_data('AAPL')

pattern = SQA::TAI.cdl_3inside(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern.last == 100
  # Three Inside Up (bullish)
  in_downtrend = close[-4] < sma_50[-4] && sma_50[-4] < sma_200[-4]

  if in_downtrend
    puts "Three Inside Up after strong downtrend!"
    puts "HIGH PROBABILITY bullish reversal"
    puts "Pattern low: #{low[-3..-1].min.round(2)}"
    puts "Current close: #{close.last.round(2)}"

    # Calculate pattern strength
    first_body = (open[-3] - close[-3]).abs
    second_body = (close[-2] - open[-2]).abs
    third_body = (close[-1] - open[-1]).abs

    puts "First candle size: #{first_body.round(2)}"
    puts "Third candle (confirmation): #{third_body.round(2)}"

    if third_body > first_body * 0.5
      puts "Strong confirmation candle - excellent setup"
    end
  else
    puts "Three Inside Up but not in clear downtrend"
    puts "Lower reliability - verify context"
  end
end
```

## Example: Three Inside Down in Uptrend

```ruby
open, high, low, close = load_ohlc_data('TSLA')

pattern = SQA::TAI.cdl_3inside(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)

if pattern.last == -100
  # Three Inside Down (bearish)
  in_uptrend = close[-4] > sma_50[-4]

  if in_uptrend
    puts "Three Inside Down after uptrend!"
    puts "HIGH PROBABILITY bearish reversal"
    puts "Pattern high: #{high[-3..-1].max.round(2)}"
    puts "Current close: #{close.last.round(2)}"

    # Check confirmation strength
    first_body = (close[-3] - open[-3]).abs
    third_body = (open[-1] - close[-1]).abs
    confirmation_ratio = (third_body / first_body * 100).round(2)

    puts "Confirmation strength: #{confirmation_ratio}%"

    if confirmation_ratio > 50
      puts "Strong confirmation - powerful reversal signal"
    end
  end
end
```

## Example: Three Inside with Volume Analysis

```ruby
open, high, low, close, volume = load_ohlc_volume_data('MSFT')

pattern = SQA::TAI.cdl_3inside(open, high, low, close)

if pattern.last != 0
  pattern_type = pattern.last > 0 ? "Three Inside Up" : "Three Inside Down"

  # Volume analysis
  vol_first = volume[-3]
  vol_second = volume[-2]
  vol_third = volume[-1]
  avg_volume = volume[-20..-1].sum / 20.0

  puts "#{pattern_type} Volume Analysis:"
  puts "First candle: #{vol_first.round(0)}"
  puts "Second candle: #{vol_second.round(0)}"
  puts "Third candle (confirmation): #{vol_third.round(0)}"
  puts "Average volume: #{avg_volume.round(0)}"

  # Ideal: High volume on confirmation candle
  if vol_third > avg_volume * 1.5
    puts "\nEXCELLENT: High volume on confirmation"
    puts "Strong conviction - reliable reversal"
  elsif vol_third > avg_volume
    puts "\nGOOD: Above average volume on confirmation"
    puts "Decent conviction"
  else
    puts "\nWEAK: Low volume on confirmation"
    puts "Less reliable - may lack follow-through"
  end

  # Check for volume pattern
  if vol_third > vol_second && vol_second > vol_first
    puts "\nIncreasing volume throughout pattern - very bullish setup"
  end
end
```

## Example: Three Inside at Support/Resistance

```ruby
open, high, low, close = load_ohlc_data('NVDA')

pattern = SQA::TAI.cdl_3inside(open, high, low, close)

# Find support and resistance
support = close[-120..-1].min
resistance = close[-120..-1].max

if pattern.last == 100  # Bullish
  distance_from_support = ((close[-3] - support) / support * 100).abs

  if distance_from_support < 2  # Within 2% of support
    puts "Three Inside Up AT MAJOR SUPPORT!"
    puts "Support level: #{support.round(2)}"
    puts "Pattern low: #{low[-3..-1].min.round(2)}"
    puts "Current close: #{close.last.round(2)}"
    puts "\nBuyers defending support - HIGH PROBABILITY reversal"

    # Calculate potential upside
    target = resistance
    potential_gain = ((target - close.last) / close.last * 100).round(2)
    puts "Potential to resistance: #{potential_gain}%"
  end

elsif pattern.last == -100  # Bearish
  distance_from_resistance = ((close[-3] - resistance) / resistance * 100).abs

  if distance_from_resistance < 2  # Within 2% of resistance
    puts "Three Inside Down AT MAJOR RESISTANCE!"
    puts "Resistance level: #{resistance.round(2)}"
    puts "Pattern high: #{high[-3..-1].max.round(2)}"
    puts "Current close: #{close.last.round(2)}"
    puts "\nSellers defending resistance - HIGH PROBABILITY reversal"

    # Calculate potential downside
    target = support
    potential_decline = ((close.last - target) / close.last * 100).round(2)
    puts "Potential to support: #{potential_decline}%"
  end
end
```

## Example: Three Inside with RSI Confirmation

```ruby
open, high, low, close = load_ohlc_data('GOOGL')

pattern = SQA::TAI.cdl_3inside(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last == 100  # Bullish
  rsi_at_pattern = rsi[-3]
  rsi_current = rsi.last

  puts "Three Inside Up with RSI:"
  puts "RSI at pattern start: #{rsi_at_pattern.round(2)}"
  puts "Current RSI: #{rsi_current.round(2)}"

  if rsi_at_pattern < 30
    puts "\nOVERSOLD RSI + Three Inside Up"
    puts "Multiple bullish signals - Strong BUY setup"
  elsif rsi_at_pattern < 40
    puts "\nLow RSI + Three Inside Up"
    puts "Good reversal confirmation"
  else
    puts "\nThree Inside Up without oversold RSI"
    puts "Moderate signal strength"
  end

elsif pattern.last == -100  # Bearish
  rsi_at_pattern = rsi[-3]
  rsi_current = rsi.last

  puts "Three Inside Down with RSI:"
  puts "RSI at pattern start: #{rsi_at_pattern.round(2)}"
  puts "Current RSI: #{rsi_current.round(2)}"

  if rsi_at_pattern > 70
    puts "\nOVERBOUGHT RSI + Three Inside Down"
    puts "Multiple bearish signals - Strong SELL setup"
  elsif rsi_at_pattern > 60
    puts "\nHigh RSI + Three Inside Down"
    puts "Good reversal confirmation"
  else
    puts "\nThree Inside Down without overbought RSI"
    puts "Moderate signal strength"
  end
end
```

## Trading Strategies

### Entry Rules

#### Conservative Entry (Recommended)
```ruby
# Wait for additional confirmation after pattern
if pattern[-2] == 100  # Bullish pattern two candles ago
  if close[-1] > close[-2]  # Another bullish close
    puts "Three Inside Up CONFIRMED - Enter LONG"
    entry = close.last
    puts "Entry: #{entry.round(2)}"
  end
elsif pattern[-2] == -100  # Bearish pattern two candles ago
  if close[-1] < close[-2]  # Another bearish close
    puts "Three Inside Down CONFIRMED - Enter SHORT"
    entry = close.last
    puts "Entry: #{entry.round(2)}"
  end
end
```

#### Aggressive Entry
```ruby
# Enter on pattern completion (third candle close)
if pattern.last == 100
  entry = close.last
  puts "Three Inside Up completed - Enter LONG at #{entry.round(2)}"
elsif pattern.last == -100
  entry = close.last
  puts "Three Inside Down completed - Enter SHORT at #{entry.round(2)}"
end
```

### Stop Loss Placement

```ruby
if pattern.last == 100  # Bullish
  # Stop below pattern low
  stop = low[-3..-1].min
  stop_with_buffer = stop * 0.995  # 0.5% buffer

  puts "Stop loss: #{stop_with_buffer.round(2)}"
  puts "Rationale: Below pattern low - invalidates bullish setup"

elsif pattern.last == -100  # Bearish
  # Stop above pattern high
  stop = high[-3..-1].max
  stop_with_buffer = stop * 1.005  # 0.5% buffer

  puts "Stop loss: #{stop_with_buffer.round(2)}"
  puts "Rationale: Above pattern high - invalidates bearish setup"
end
```

### Profit Targets

```ruby
if pattern.last == 100  # Bullish
  entry = close.last
  stop = low[-3..-1].min * 0.995
  risk = entry - stop

  # Multiple targets
  target_1 = entry + (risk * 2)    # 2:1 R:R
  target_2 = entry + (risk * 3)    # 3:1 R:R
  target_3 = entry + (risk * 5)    # 5:1 R:R

  puts "Profit Targets (Long):"
  puts "T1 (2:1): #{target_1.round(2)}"
  puts "T2 (3:1): #{target_2.round(2)}"
  puts "T3 (5:1): #{target_3.round(2)}"

elsif pattern.last == -100  # Bearish
  entry = close.last
  stop = high[-3..-1].max * 1.005
  risk = stop - entry

  # Multiple targets
  target_1 = entry - (risk * 2)    # 2:1 R:R
  target_2 = entry - (risk * 3)    # 3:1 R:R
  target_3 = entry - (risk * 5)    # 5:1 R:R

  puts "Profit Targets (Short):"
  puts "T1 (2:1): #{target_1.round(2)}"
  puts "T2 (3:1): #{target_2.round(2)}"
  puts "T3 (5:1): #{target_3.round(2)}"
end
```

## Example: Complete Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('AMZN')

pattern = SQA::TAI.cdl_3inside(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern.last != 0
  is_bullish = pattern.last > 0
  pattern_name = is_bullish ? "Three Inside Up" : "Three Inside Down"

  puts "#{pattern_name} Pattern Detected"
  puts "=" * 50

  # 1. Trend verification
  proper_trend = if is_bullish
    close[-4] < sma_50[-4]  # Downtrend for bullish pattern
  else
    close[-4] > sma_50[-4]  # Uptrend for bearish pattern
  end

  # 2. RSI check
  rsi_val = rsi[-3]
  rsi_favorable = is_bullish ? rsi_val < 40 : rsi_val > 60

  # 3. Volume analysis
  avg_vol = volume[-20..-1].sum / 20.0
  vol_confirmation = volume[-1] > avg_vol * 1.2

  # 4. Support/Resistance check
  support = close[-120..-1].min
  resistance = close[-120..-1].max
  near_key_level = if is_bullish
    (low[-3..-1].min - support).abs < support * 0.03
  else
    (high[-3..-1].max - resistance).abs < resistance * 0.03
  end

  # 5. Pattern quality check
  first_body = (open[-3] - close[-3]).abs
  third_body = (close[-1] - open[-1]).abs
  strong_confirmation = third_body > first_body * 0.4

  # 6. Second candle positioning
  second_range = high[-2] - low[-2]
  first_range = high[-3] - low[-3]
  well_inside = second_range < first_range * 0.7

  # Calculate score
  score = 0
  score += 1 if proper_trend
  score += 1 if rsi_favorable
  score += 1 if vol_confirmation
  score += 1 if near_key_level
  score += 1 if strong_confirmation
  score += 1 if well_inside

  puts "Setup Analysis:"
  puts "Proper trend context: #{proper_trend}"
  puts "RSI favorable (#{rsi_val.round(2)}): #{rsi_favorable}"
  puts "Volume confirmation: #{vol_confirmation}"
  puts "Near key level: #{near_key_level}"
  puts "Strong confirmation: #{strong_confirmation}"
  puts "Well inside pattern: #{well_inside}"
  puts "\nSetup Score: #{score}/6"

  if score >= 4
    entry = close.last

    if is_bullish
      stop = low[-3..-1].min * 0.995
      risk = entry - stop
      target = entry + (risk * 3)
      direction = "LONG"
    else
      stop = high[-3..-1].max * 1.005
      risk = stop - entry
      target = entry - (risk * 3)
      direction = "SHORT"
    end

    puts "\n*** HIGH PROBABILITY #{direction} SETUP ***"
    puts "Entry: #{entry.round(2)}"
    puts "Stop: #{stop.round(2)}"
    puts "Target: #{target.round(2)}"
    puts "Risk: $#{risk.round(2)}"
    puts "Reward: $#{(target - entry).abs.round(2)}"
    puts "R:R Ratio: 1:3"

    # Position sizing
    account_size = 100000
    risk_percent = 0.01  # 1% account risk
    risk_amount = account_size * risk_percent
    shares = (risk_amount / risk).floor
    puts "\nPosition Size: #{shares} shares"
    puts "Total risk: $#{risk_amount.round(2)} (1% of account)"

  elsif score >= 3
    puts "\nDECENT SETUP - Consider reduced position size"
  else
    puts "\nLOW PROBABILITY - Skip this trade"
  end
end
```

## Pattern Statistics

### Frequency
- **Occurrence**: Moderate (2-3% of the time)
- **Best Timeframes**: Daily, 4-hour (more reliable)
- **Markets**: Works on all markets (stocks, forex, crypto)

### Success Rate
- **With confirmation**: 70-78% success rate
- **Without confirmation**: 55-65% success rate
- **At support/resistance**: 75-82% success rate
- **With volume**: 72-80% success rate
- **With RSI extremes**: 75-83% success rate

### Average Move
- **Typical move**: 8-15% from pattern completion
- **Major reversals**: 20-35% move possible
- **Time to target**: 5-15 candles (varies by timeframe)

## Best Practices

### Do's
1. Wait for proper trend context before taking signal
2. Verify second candle is well inside first candle
3. Look for strong confirmation on third candle
4. Check for volume increase on confirmation
5. Trade near support/resistance for best results
6. Use with RSI extremes for stronger signal
7. Calculate risk/reward before entry
8. Scale out at multiple targets

### Don'ts
1. Don't trade pattern without trend context
2. Don't ignore volume (confirms conviction)
3. Don't enter without proper stop loss
4. Don't trade if second candle is near edge
5. Don't ignore broader market context
6. Don't risk more than 1-2% of account
7. Don't chase if pattern is not at key level
8. Don't confuse with standalone harami

## Common Mistakes

1. **Trading without trend**: Pattern requires proper trend for reversal
2. **Weak confirmation**: Third candle must strongly confirm direction
3. **Poor stop placement**: Must be beyond pattern extreme
4. **No volume check**: Volume confirms conviction
5. **Confusing with harami**: Three Inside has confirmation candle

## Related Patterns

### Similar Patterns
- [Engulfing](cdl_engulfing.md) - Two-candle reversal (harami is inverse)
- [Three Outside Up/Down](cdl_3outside.md) - Uses engulfing instead of harami
- [Harami](cdl_harami.md) - Two-candle pattern without confirmation
- [Morning/Evening Star](cdl_morningstar.md) - Three-candle reversal with gap

### Component Patterns
- Harami pattern forms first two candles
- Confirmation candle completes the pattern

## Pattern Variations

### Strong Three Inside
- Large first candle (shows exhaustion)
- Second candle well-centered in first
- Strong third candle (> 50% of first)
- High volume on confirmation
- At major support/resistance
- **Success Rate**: 78-85%

### Average Three Inside
- Medium first candle
- Second candle positioned well
- Decent third candle confirmation
- Normal volume
- Clear trend context
- **Success Rate**: 65-72%

### Weak Three Inside
- Small first candle
- Second candle near edge of first
- Weak third candle confirmation
- Low volume
- No clear trend or level
- **Success Rate**: 45-55%

## Key Takeaways

1. **Reliable reversal pattern** when all conditions align
2. **Confirmation is key** - third candle validates reversal
3. **Trend context required** - must appear at trend extremes
4. **Volume matters** - confirms conviction on reversal
5. **Better than harami alone** - three candles reduce false signals
6. **Support/resistance confluence** improves success rate
7. **Risk management essential** - always use stops
8. **Scale entries** - better results with partial positions

## See Also

- [Three Outside Up/Down](cdl_3outside.md) - Related three-candle pattern
- [Engulfing Pattern](cdl_engulfing.md) - Two-candle reversal
- [Harami Pattern](cdl_harami.md) - Inside pattern without confirmation
- [Morning/Evening Star](cdl_morningstar.md) - Three-candle reversal
- [Pattern Recognition Overview](../index.md)
- [Back to Indicators](../index.md)
