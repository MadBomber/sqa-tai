# Three Line Strike Pattern

The Three Line Strike is a powerful four-candlestick reversal pattern that appears in both bullish and bearish forms. It consists of three consecutive candles moving in one direction, followed by a fourth candle that completely engulfs the prior three, signaling a potential reversal of the established trend.

## Pattern Type

- **Type**: Reversal (Both Bullish and Bearish)
- **Candles Required**: 4
- **Trend Context**: Can appear in uptrends (bearish variant) or downtrends (bullish variant)
- **Reliability**: High (one of the most reliable reversal patterns)
- **Frequency**: Rare (appears less than 1% of the time)

## Usage

```ruby
require 'sqa/tai'

open  = [100.0, 101.0, 102.0, 103.0, 99.0]
high  = [101.5, 102.5, 103.5, 104.0, 104.5]
low   = [99.5, 100.5, 101.5, 102.5, 98.5]
close = [101.0, 102.0, 103.0, 103.5, 104.0]

# Detect Three Line Strike pattern
pattern = SQA::TAI.cdl_3linestrike(open, high, low, close)

if pattern.last == 100
  puts "Bullish Three Line Strike - Strong reversal signal!"
elsif pattern.last == -100
  puts "Bearish Three Line Strike - Strong reversal signal!"
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
- **0**: No Three Line Strike pattern detected
- **+100**: Bullish Three Line Strike (reversal from downtrend)
- **-100**: Bearish Three Line Strike (reversal from uptrend)

## Pattern Recognition Rules

### Bullish Three Line Strike (Four Candle Structure)

1. **First Three Candles**: Three consecutive bearish candles (resembling Three Black Crows)
   - Each opens within previous body
   - Each closes progressively lower
   - All three are bearish

2. **Fourth Candle**: Large bullish candle that:
   - Opens at or below the third candle's close
   - Rallies strongly upward
   - Closes above the first candle's open
   - Completely engulfs all three prior candles

### Bearish Three Line Strike (Four Candle Structure)

1. **First Three Candles**: Three consecutive bullish candles (resembling Three White Soldiers)
   - Each opens within previous body
   - Each closes progressively higher
   - All three are bullish

2. **Fourth Candle**: Large bearish candle that:
   - Opens at or above the third candle's close
   - Sells off strongly downward
   - Closes below the first candle's open
   - Completely engulfs all three prior candles

### Key Characteristics

- First three candles show clear directional momentum
- Fourth candle is a complete reversal
- Fourth candle must engulf entire range of first three
- High volume on fourth candle confirms strength
- Pattern shows failed continuation becoming powerful reversal

## Visual Pattern

```
Bullish Three Line Strike (in downtrend):

       [========]    Fourth candle (huge bullish, engulfs all)
       |        |
    [===]
     |  |          Third bearish candle
   [===]
    | |            Second bearish candle
  [===]
   | |             First bearish candle

Bearish Three Line Strike (in uptrend):

  [===]
   | |             First bullish candle
   [===]
    | |            Second bullish candle
    [===]
     |  |          Third bullish candle
       |        |
       [========]  Fourth candle (huge bearish, engulfs all)
```

## Interpretation

The Three Line Strike signals a powerful reversal through:

1. **False Continuation**: First three candles appear to continue trend
2. **Capitulation**: Fourth candle shows complete rejection
3. **Absorption**: All selling/buying in first three candles absorbed
4. **Momentum Shift**: Direction completely reverses
5. **Psychological Impact**: Traders positioned for continuation get trapped

### Reliability Factors

| Factor | Low Reliability | Medium Reliability | High Reliability |
|--------|----------------|-------------------|------------------|
| Fourth Candle Size | Barely engulfs | Good engulfment | Deep engulfment |
| Volume | Normal | Above average | Exceptionally high |
| Trend Strength | Weak trend | Clear trend | Strong trend |
| First Three Quality | Variable sizes | Consistent | Uniform progression |
| Location | Mid-chart | Near S/R | At major S/R level |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Example: Bullish Three Line Strike

```ruby
open, high, low, close = load_ohlc_data('AAPL')

pattern = SQA::TAI.cdl_3linestrike(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern.last == 100
  # Verify downtrend context
  was_downtrend = close[-5] < sma_50[-5] && sma_50[-5] < sma_200[-5]

  if was_downtrend
    puts "Bullish Three Line Strike after downtrend!"
    puts "HIGH PROBABILITY reversal"

    # Measure the strike candle
    strike_body = close.last - open.last
    avg_prior = (close[-4] - open[-4]).abs +
                (close[-3] - open[-3]).abs +
                (close[-2] - open[-2]).abs
    avg_prior /= 3.0

    strike_ratio = strike_body / avg_prior
    puts "Strike candle is #{strike_ratio.round(2)}x average prior candles"

    if strike_ratio > 2.0
      puts "VERY STRONG reversal candle"
    elsif strike_ratio > 1.5
      puts "Strong reversal candle"
    else
      puts "Moderate reversal candle"
    end

    # Check engulfment quality
    first_open = open[-4]
    third_low = low[-2]
    engulfs = close.last > first_open && open.last < third_low

    puts "Complete engulfment: #{engulfs}"
  end
end
```

## Example: Bearish Three Line Strike with Volume

```ruby
open, high, low, close, volume = load_ohlc_volume_data('TSLA')

pattern = SQA::TAI.cdl_3linestrike(open, high, low, close)

if pattern.last == -100
  # Volume analysis
  vol_soldiers = volume[-4..-2]  # First three bullish
  vol_strike = volume[-1]         # Strike candle
  avg_volume = volume[-20..-5].sum / 16.0

  puts "Bearish Three Line Strike Volume Analysis:"
  puts "Soldiers average: #{(vol_soldiers.sum / 3.0).round(0)}"
  puts "Strike volume: #{vol_strike.round(0)}"
  puts "Average volume: #{avg_volume.round(0)}"

  vol_ratio = vol_strike / (vol_soldiers.sum / 3.0)
  puts "Strike volume ratio: #{vol_ratio.round(2)}x"

  if vol_strike > avg_volume * 2 && vol_ratio > 1.5
    puts "\nEXCELLENT: Massive volume on strike candle"
    puts "High conviction reversal - VERY STRONG"
  elsif vol_strike > avg_volume && vol_ratio > 1.2
    puts "\nGOOD: Elevated volume on strike"
    puts "Strong reversal signal"
  else
    puts "\nMODERATE: Normal volume"
    puts "Watch for confirmation"
  end
end
```

## Example: Three Line Strike at Support/Resistance

```ruby
open, high, low, close = load_ohlc_data('MSFT')

pattern = SQA::TAI.cdl_3linestrike(open, high, low, close)

if pattern.last == 100
  # Find support level
  support = close[-120..-1].min
  pattern_low = low[-2]  # Low of third candle

  distance = ((pattern_low - support).abs / support * 100).round(2)

  if distance < 2
    puts "Bullish Three Line Strike AT SUPPORT!"
    puts "Support: #{support.round(2)}"
    puts "Pattern low: #{pattern_low.round(2)}"
    puts "Distance: #{distance}%"
    puts "\nPerfect reversal setup - bounce from support"
    puts "VERY HIGH PROBABILITY"
  end
elsif pattern.last == -100
  # Find resistance level
  resistance = close[-120..-1].max
  pattern_high = high[-2]  # High of third candle

  distance = ((pattern_high - resistance).abs / resistance * 100).round(2)

  if distance < 2
    puts "Bearish Three Line Strike AT RESISTANCE!"
    puts "Resistance: #{resistance.round(2)}"
    puts "Pattern high: #{pattern_high.round(2)}"
    puts "Distance: #{distance}%"
    puts "\nPerfect reversal setup - rejection at resistance"
    puts "VERY HIGH PROBABILITY"
  end
end
```

## Example: Three Line Strike with RSI

```ruby
open, high, low, close = load_ohlc_data('NVDA')

pattern = SQA::TAI.cdl_3linestrike(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last == 100
  rsi_at_low = rsi[-2]   # RSI at third bearish candle
  rsi_current = rsi.last

  puts "Bullish Three Line Strike with RSI:"
  puts "RSI at pattern low: #{rsi_at_low.round(2)}"
  puts "Current RSI: #{rsi_current.round(2)}"

  if rsi_at_low < 30
    puts "\nPattern formed from OVERSOLD"
    puts "Classic reversal from extremes - STRONG"
  elsif rsi_at_low < 40
    puts "\nPattern from depressed RSI - Good setup"
  end

  rsi_jump = rsi_current - rsi_at_low
  puts "RSI jump: #{rsi_jump.round(2)} points"

  if rsi_jump > 20
    puts "Massive momentum shift!"
  end

elsif pattern.last == -100
  rsi_at_high = rsi[-2]
  rsi_current = rsi.last

  puts "Bearish Three Line Strike with RSI:"
  puts "RSI at pattern high: #{rsi_at_high.round(2)}"
  puts "Current RSI: #{rsi_current.round(2)}"

  if rsi_at_high > 70
    puts "\nPattern formed from OVERBOUGHT"
    puts "Classic reversal from extremes - STRONG"
  end
end
```

## Trading Strategies

### Entry Rules

#### Conservative Entry (Recommended)
```ruby
# Wait for confirmation candle after pattern
if pattern[-2] == 100  # Bullish pattern two candles ago
  if close[-1] > close[-2] || close.last > close[-1]
    puts "Bullish Three Line Strike CONFIRMED"
    entry = close.last
    puts "Enter LONG at #{entry.round(2)}"
  end
elsif pattern[-2] == -100  # Bearish pattern
  if close[-1] < close[-2] || close.last < close[-1]
    puts "Bearish Three Line Strike CONFIRMED"
    entry = close.last
    puts "Enter SHORT at #{entry.round(2)}"
  end
end
```

#### Aggressive Entry
```ruby
# Enter immediately on pattern completion (fourth candle close)
if pattern.last == 100
  entry = close.last
  puts "Bullish Three Line Strike - Enter LONG"
  puts "Entry: #{entry.round(2)}"
elsif pattern.last == -100
  entry = close.last
  puts "Bearish Three Line Strike - Enter SHORT"
  puts "Entry: #{entry.round(2)}"
end
```

#### Pullback Entry
```ruby
# Wait for minor pullback to better entry
if pattern[-3] == 100  # Bullish pattern 3 candles ago
  if close.last < close[-1] && close.last > close[-3]
    puts "Pullback after bullish strike - Enter LONG"
    puts "Entry: #{close.last.round(2)}"
  end
end
```

### Stop Loss Placement

```ruby
if pattern.last == 100
  # Stop below the third candle's low (before strike)
  stop = low[-2] * 0.99  # 1% buffer

  puts "Stop loss: #{stop.round(2)}"
  puts "Rationale: Below pattern low before strike"

  entry = close.last
  risk = entry - stop
  risk_percent = (risk / entry * 100).round(2)
  puts "Risk: $#{risk.round(2)} (#{risk_percent}%)"

elsif pattern.last == -100
  # Stop above the third candle's high (before strike)
  stop = high[-2] * 1.01  # 1% buffer

  puts "Stop loss: #{stop.round(2)}"
  puts "Rationale: Above pattern high before strike"

  entry = close.last
  risk = stop - entry
  risk_percent = (risk / entry * 100).round(2)
  puts "Risk: $#{risk.round(2)} (#{risk_percent}%)"
end
```

### Profit Targets

```ruby
if pattern.last == 100
  entry = close.last
  stop = low[-2] * 0.99
  risk = entry - stop

  # Risk-based targets
  target_1 = entry + (risk * 2)    # 2:1 R:R
  target_2 = entry + (risk * 3)    # 3:1 R:R
  target_3 = entry + (risk * 5)    # 5:1 R:R

  puts "Long Targets:"
  puts "T1 (2:1): #{target_1.round(2)}"
  puts "T2 (3:1): #{target_2.round(2)}"
  puts "T3 (5:1): #{target_3.round(2)}"

  # Resistance-based target
  resistance = close[-120..-1].max
  puts "Resistance target: #{resistance.round(2)}"

elsif pattern.last == -100
  entry = close.last
  stop = high[-2] * 1.01
  risk = stop - entry

  target_1 = entry - (risk * 2)
  target_2 = entry - (risk * 3)
  target_3 = entry - (risk * 5)

  puts "Short Targets:"
  puts "T1 (2:1): #{target_1.round(2)}"
  puts "T2 (3:1): #{target_2.round(2)}"
  puts "T3 (5:1): #{target_3.round(2)}"

  # Support-based target
  support = close[-120..-1].min
  puts "Support target: #{support.round(2)}"
end
```

## Example: Complete Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('GOOGL')

pattern = SQA::TAI.cdl_3linestrike(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern.last != 0
  is_bullish = pattern.last == 100

  puts "Three Line Strike #{is_bullish ? 'BULLISH' : 'BEARISH'}"
  puts "=" * 60

  # 1. Trend verification
  if is_bullish
    was_downtrend = close[-5] < sma_50[-5] && sma_50[-5] < sma_200[-5]
    trend_ok = was_downtrend
  else
    was_uptrend = close[-5] > sma_50[-5] && sma_50[-5] > sma_200[-5]
    trend_ok = was_uptrend
  end

  # 2. Strike candle quality
  strike_body = (close.last - open.last).abs
  prior_bodies = [-4, -3, -2].map { |i| (close[i] - open[i]).abs }
  avg_prior = prior_bodies.sum / 3.0
  strike_ratio = strike_body / avg_prior
  strong_strike = strike_ratio > 1.5

  # 3. Engulfment quality
  if is_bullish
    full_engulf = close.last > open[-4] && open.last < low[-2]
  else
    full_engulf = close.last < open[-4] && open.last > high[-2]
  end

  # 4. Volume analysis
  avg_vol = volume[-20..-5].sum / 16.0
  strike_vol = volume[-1]
  high_volume = strike_vol > avg_vol * 1.5

  # 5. RSI confirmation
  rsi_before = rsi[-2]
  if is_bullish
    rsi_ok = rsi_before < 40
  else
    rsi_ok = rsi_before > 60
  end

  # 6. Support/Resistance proximity
  if is_bullish
    support = close[-120..-1].min
    near_level = (low[-2] - support).abs < support * 0.03
  else
    resistance = close[-120..-1].max
    near_level = (high[-2] - resistance).abs < resistance * 0.03
  end

  # Calculate score
  score = 0
  score += 2 if trend_ok           # Critical
  score += 2 if strong_strike      # Very important
  score += 2 if full_engulf        # Very important
  score += 1 if high_volume
  score += 1 if rsi_ok
  score += 2 if near_level         # Very important

  puts "Setup Quality Checks:"
  puts "1. Proper trend context: #{trend_ok} #{trend_ok ? '✓✓' : '✗✗'}"
  puts "2. Strong strike (#{strike_ratio.round(2)}x): #{strong_strike} #{strong_strike ? '✓✓' : '✗'}"
  puts "3. Full engulfment: #{full_engulf} #{full_engulf ? '✓✓' : '✗'}"
  puts "4. High volume: #{high_volume} #{high_volume ? '✓' : '✗'}"
  puts "5. RSI favorable: #{rsi_ok} #{rsi_ok ? '✓' : '✗'}"
  puts "6. Near S/R level: #{near_level} #{near_level ? '✓✓' : '✗'}"
  puts "\nTotal Score: #{score}/10"

  if score >= 7
    entry = close.last
    if is_bullish
      stop = low[-2] * 0.99
      risk = entry - stop
      target = entry + (risk * 3)
    else
      stop = high[-2] * 1.01
      risk = stop - entry
      target = entry - (risk * 3)
    end

    reward = (target - entry).abs
    rr_ratio = (reward / risk).round(1)

    puts "\n*** EXCELLENT #{is_bullish ? 'LONG' : 'SHORT'} SETUP ***"
    puts "-" * 60
    puts "Entry: $#{entry.round(2)}"
    puts "Stop: $#{stop.round(2)}"
    puts "Target: $#{target.round(2)}"
    puts "Risk: $#{risk.round(2)} (#{(risk/entry*100).round(2)}%)"
    puts "Reward: $#{reward.round(2)} (#{(reward/entry*100).round(2)}%)"
    puts "R:R Ratio: 1:#{rr_ratio}"

    # Position sizing
    account_size = 100000
    risk_amount = account_size * 0.02  # 2% risk
    shares = (risk_amount / risk).floor

    puts "\nPosition Sizing (2% risk):"
    puts "Shares: #{shares}"
    puts "Position value: $#{(shares * entry).round(2)}"
    puts "Total risk: $#{risk_amount.round(2)}"
    puts "Potential profit: $#{(shares * reward).round(2)}"

  elsif score >= 5
    puts "\nDECENT SETUP - Reduced position size"
  else
    puts "\nWEAK SETUP - SKIP"
  end
end
```

## Pattern Statistics

### Frequency
- **Occurrence**: Rare (less than 1% of the time)
- **Best Timeframes**: Daily, Weekly (most reliable)
- **Markets**: All markets (stocks, forex, crypto, commodities)

### Success Rate
- **Perfect setup**: 80-88% success rate
- **Good setup**: 70-78% success rate
- **Average setup**: 60-70% success rate
- **At support/resistance**: 82-90% success rate
- **With volume**: 75-85% success rate

### Average Move
- **Initial move**: 5-15% in reversal direction
- **Major reversals**: 20-50% possible
- **Time to target**: 5-15 candles
- **Follow-through**: 75% show continuation after pattern

## Best Practices

### Do's
1. Verify proper trend context before pattern
2. Confirm fourth candle completely engulfs first three
3. Look for high volume on strike candle
4. Trade near major support/resistance levels
5. Check RSI for extreme readings before pattern
6. Wait for confirmation in choppy markets
7. Use proper stop loss below/above pattern extremes
8. Scale out at multiple profit targets
9. Verify first three candles show clear progression
10. Give pattern room to work (3-5 candles minimum)

### Don'ts
1. Don't trade without proper trend context
2. Don't ignore engulfment quality (critical)
3. Don't trade on low volume strike candle
4. Don't enter without stop loss
5. Don't confuse with regular engulfing patterns
6. Don't trade if fourth candle barely engulfs
7. Don't chase if entry missed
8. Don't ignore broader market conditions
9. Don't risk more than 2% account per trade
10. Don't trade if first three candles are inconsistent

## Common Mistakes

1. **Misidentifying pattern**: Requires complete engulfment of all three prior candles
2. **Wrong trend context**: Pattern must appear in established trend
3. **Poor stop placement**: Must be beyond pattern extremes
4. **Ignoring volume**: Strike candle volume is critical
5. **Entering too early**: Wait for fourth candle to complete
6. **Weak engulfment**: Fourth candle must be decisive
7. **No confirmation**: Better results with follow-through candle

## Related Patterns

### Similar Reversal Patterns
- [Three Black Crows](cdl_3blackcrows.md) - First three candles of bearish version
- [Three White Soldiers](cdl_3whitesoldiers.md) - First three candles of bullish version
- [Engulfing](cdl_engulfing.md) - Two-candle engulfing pattern
- [Morning Star](cdl_morningstar.md) - Three-candle bullish reversal
- [Evening Star](cdl_eveningstar.md) - Three-candle bearish reversal

### Component Patterns
- [Marubozu](cdl_marubozu.md) - Strike candle often resembles this
- [Long Line](cdl_longline.md) - Strike candle characteristics

## Pattern Variations

### Perfect Three Line Strike
- First three candles show clear, consistent progression
- Fourth candle engulfs by significant margin
- Very high volume on fourth candle
- Appears at major support/resistance
- RSI at extremes before pattern
- **Success Rate**: 85-90%

### Strong Three Line Strike
- Good progression in first three
- Clear engulfment on fourth
- Above average volume
- Clear trend context
- **Success Rate**: 70-80%

### Weak Three Line Strike
- Inconsistent first three candles
- Barely engulfs on fourth
- Low volume
- Unclear trend
- **Success Rate**: 50-60%

## Key Takeaways

1. **Rare but powerful** - One of best reversal patterns when perfect
2. **Complete engulfment required** - Fourth candle must engulf all three
3. **Trend context critical** - Must appear in established trend
4. **Volume confirms** - High volume on strike candle essential
5. **Support/resistance** - Best at major technical levels
6. **Fourth candle decisive** - Shows complete momentum shift
7. **High reliability** - 75-85% success with proper setup
8. **Risk/reward excellent** - Tight stops, large targets
9. **Patience required** - Don't anticipate, wait for completion
10. **Confirmation helps** - Fifth candle confirmation reduces risk

## See Also

- [Three Black Crows](cdl_3blackcrows.md)
- [Three White Soldiers](cdl_3whitesoldiers.md)
- [Engulfing](cdl_engulfing.md)
- [Morning Star](cdl_morningstar.md)
- [Evening Star](cdl_eveningstar.md)
- [Pattern Recognition Overview](../index.md)
- [Back to Indicators](../index.md)
