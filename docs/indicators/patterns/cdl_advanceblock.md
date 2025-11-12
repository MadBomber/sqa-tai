# Advance Block Pattern

The Advance Block is a three-candle bearish reversal pattern that appears during an uptrend and signals weakening bullish momentum. It consists of three consecutive white (bullish) candles where each subsequent candle shows diminishing strength - smaller bodies, longer upper shadows, and declining momentum. This pattern is considered a warning of an impending trend reversal rather than an immediate signal.

## Pattern Type

- **Type**: Reversal (Bearish)
- **Candles Required**: 3
- **Trend Context**: Appears during uptrends
- **Reliability**: Moderate to High
- **Frequency**: Uncommon (appears 2-3% of the time)

## Usage

```ruby
require 'sqa/tai'

# Advance Block example
open  = [95.0, 97.0, 98.5, 99.2, 99.4]
high  = [97.5, 99.0, 100.0, 100.2, 100.0]
low   = [94.5, 96.5, 98.0, 98.8, 99.0]
close = [97.0, 98.5, 99.5, 99.7, 99.5]

# Detect Advance Block pattern
pattern = SQA::TAI.cdl_advanceblock(open, high, low, close)

if pattern.last == -100
  puts "Advance Block detected - Uptrend losing steam!"
  puts "Warning: Potential reversal ahead"
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
- **0**: No Advance Block pattern detected
- **-100**: Advance Block pattern detected (bearish reversal warning)

## Pattern Recognition Rules

### Advance Block (Bearish Warning)

1. **First Candle**: Long white candle
   - Strong bullish body
   - Continues the uptrend
   - Relatively small upper shadow
   - Normal or high volume

2. **Second Candle**: Medium white candle
   - Opens within first candle's body
   - Body is smaller than first candle
   - Upper shadow is longer than first
   - Close is higher but momentum weakening
   - Volume typically declining

3. **Third Candle**: Small white candle
   - Opens within second candle's body
   - Body is smaller than second candle
   - Upper shadow is longest of three
   - Close barely advances
   - Volume further declining
   - Shows exhaustion

### Key Characteristics

- **Progressive weakening**: Each candle shows less strength
- **Diminishing bodies**: Body size decreases with each candle
- **Lengthening shadows**: Upper shadows increase progressively
- **Declining volume**: Volume typically decreases through pattern
- **Higher closes**: All three candles close higher than previous
- **Within bodies**: Each open is within previous body
- **Uptrend context**: Must occur during established uptrend
- **Exhaustion signal**: Buyers losing control gradually

### Ideal Pattern Features

- **Clear progression**: Obvious decrease in body sizes
- **Long upper shadows**: Third candle has significant upper shadow
- **Volume decline**: Clear volume reduction through pattern
- **Extended uptrend**: Pattern appears after strong rally
- **Consecutive candles**: All three are consecutive white candles
- **Resistance level**: Forms at or near key resistance

## Visual Pattern

```
Advance Block (Bearish Warning):

       |           Third: Small white, long upper shadow
      [=]                (buyers exhausted)
       |
       |
      |
     [==]         Second: Medium white, longer shadow
      |                  (momentum fading)
      |

    [====]        First: Long white candle
     |  |               (strong but last push)


Progressively smaller bodies and longer shadows
Buyers advancing but losing strength
```

## Interpretation

The Advance Block signals trend exhaustion through:

1. **Diminishing Power**: Each candle shows less buying power
2. **Shadow Extension**: Increasing upper shadows show rejection
3. **Volume Decline**: Decreasing participation signals weakness
4. **Buyer Exhaustion**: Bulls unable to sustain momentum
5. **Distribution**: Early warning of potential distribution
6. **Caution Signal**: Time to protect long positions

### Reliability Factors

| Factor | Low Reliability | Medium Reliability | High Reliability |
|--------|----------------|-------------------|------------------|
| Trend Strength | Weak uptrend | Clear uptrend | Strong/extended uptrend |
| Body Progression | Irregular sizes | Some decrease | Clear progressive decrease |
| Shadow Growth | No pattern | Some increase | Clear progressive increase |
| Volume Pattern | No decline | Some decline | Clear volume decline |
| Resistance Level | Random location | Near resistance | At major resistance |
| Prior Rally | Weak | Moderate | Strong/extended |

## Example: Advance Block at Resistance

```ruby
open, high, low, close = load_ohlc_data('AAPL')

pattern = SQA::TAI.cdl_advanceblock(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last == -100
  puts "Advance Block detected!"

  # Verify uptrend context
  uptrend = close[-4] > sma_50[-4] &&
            close[-4] > close[-10]

  # Analyze candle progression
  body1 = (close[-3] - open[-3]).abs
  body2 = (close[-2] - open[-2]).abs
  body3 = (close[-1] - open[-1]).abs

  puts "\nBody Size Analysis:"
  puts "First candle: $#{body1.round(2)}"
  puts "Second candle: $#{body2.round(2)} (#{((body2/body1)*100).round(1)}% of first)"
  puts "Third candle: $#{body3.round(2)} (#{((body3/body2)*100).round(1)}% of second)"

  if body1 > body2 && body2 > body3
    puts "\nCLEAR PROGRESSION - bodies decreasing"
  end

  # Analyze upper shadows
  shadow1 = high[-3] - close[-3]
  shadow2 = high[-2] - close[-2]
  shadow3 = high[-1] - close[-1]

  puts "\nUpper Shadow Analysis:"
  puts "First: $#{shadow1.round(2)}"
  puts "Second: $#{shadow2.round(2)}"
  puts "Third: $#{shadow3.round(2)}"

  if shadow1 < shadow2 && shadow2 < shadow3
    puts "INCREASING REJECTION - shadows growing"
  end

  # Check resistance
  recent_high = close[-20..-4].max
  near_resistance = close.last >= recent_high * 0.98

  if uptrend && body1 > body2 && body2 > body3
    puts "\n*** TEXTBOOK ADVANCE BLOCK ***"
    puts "Clear warning of trend exhaustion"
    puts "RSI: #{rsi.last.round(2)}"

    if rsi.last > 70
      puts "OVERBOUGHT + Advance Block = Strong warning"
    end

    if near_resistance
      puts "At resistance - reversal more likely"
    end
  end
end
```

## Example: Volume Confirmation

```ruby
open, high, low, close, volume = load_ohlc_volume_data('TSLA')

pattern = SQA::TAI.cdl_advanceblock(open, high, low, close)

if pattern.last == -100
  puts "Advance Block detected"

  # Analyze volume progression
  vol1 = volume[-3]
  vol2 = volume[-2]
  vol3 = volume[-1]
  avg_vol = volume[-20..-4].sum / 17.0

  puts "\nVolume Analysis:"
  puts "First candle: #{vol1.round(0)} (#{(vol1/avg_vol).round(2)}x avg)"
  puts "Second candle: #{vol2.round(0)} (#{(vol2/avg_vol).round(2)}x avg)"
  puts "Third candle: #{vol3.round(0)} (#{(vol3/avg_vol).round(2)}x avg)"

  # Ideal: declining volume through pattern
  declining_volume = vol1 > vol2 && vol2 > vol3

  if declining_volume
    puts "\nIDEAL VOLUME PATTERN:"
    puts "- Volume declining through pattern"
    puts "- Confirms loss of buying pressure"
    puts "- Strong warning signal"

    vol_decline_pct = ((vol1 - vol3) / vol1 * 100).round(1)
    puts "Volume declined #{vol_decline_pct}% through pattern"

  elsif vol3 < avg_vol
    puts "\nGOOD: Final candle shows weak volume"
    puts "Confirms exhaustion"

  else
    puts "\nWARNING: Volume not confirming"
    puts "Pattern less reliable without volume decline"
  end
end
```

## Example: Momentum Decline

```ruby
open, high, low, close = load_ohlc_data('MSFT')

pattern = SQA::TAI.cdl_advanceblock(open, high, low, close)

if pattern.last == -100
  puts "Advance Block - Momentum Analysis"

  # Calculate momentum for each candle
  momentum1 = close[-3] - open[-3]
  momentum2 = close[-2] - open[-2]
  momentum3 = close[-1] - open[-1]

  puts "\nMomentum (Price Gain):"
  puts "First: $#{momentum1.round(2)}"
  puts "Second: $#{momentum2.round(2)} (#{((momentum2/momentum1)*100).round(1)}% of first)"
  puts "Third: $#{momentum3.round(2)} (#{((momentum3/momentum1)*100).round(1)}% of first)"

  # Calculate deceleration
  decel_1_2 = ((momentum1 - momentum2) / momentum1 * 100).round(1)
  decel_2_3 = ((momentum2 - momentum3) / momentum2 * 100).round(1)

  puts "\nDeceleration:"
  puts "First to second: #{decel_1_2}%"
  puts "Second to third: #{decel_2_3}%"

  if decel_1_2 > 30 && decel_2_3 > 30
    puts "\nSEVERE DECELERATION"
    puts "Momentum declining rapidly"
    puts "Strong reversal warning"
  elsif decel_1_2 > 20 || decel_2_3 > 20
    puts "\nCLEAR DECELERATION"
    puts "Uptrend losing steam"
  end

  # Project potential reversal
  if momentum3 < momentum1 * 0.3
    puts "\nThird candle gain < 30% of first"
    puts "Exhaustion evident - reversal likely"
  end
end
```

## Example: Shadow Analysis

```ruby
open, high, low, close = load_ohlc_data('NVDA')

pattern = SQA::TAI.cdl_advanceblock(open, high, low, close)

if pattern.last == -100
  puts "Advance Block - Shadow Analysis"

  # Calculate upper shadows
  upper_shadow1 = high[-3] - close[-3]
  upper_shadow2 = high[-2] - close[-2]
  upper_shadow3 = high[-1] - close[-1]

  # Calculate shadow as percentage of range
  range1 = high[-3] - low[-3]
  range2 = high[-2] - low[-2]
  range3 = high[-1] - low[-1]

  shadow_pct1 = (upper_shadow1 / range1 * 100).round(1)
  shadow_pct2 = (upper_shadow2 / range2 * 100).round(1)
  shadow_pct3 = (upper_shadow3 / range3 * 100).round(1)

  puts "\nUpper Shadow as % of Range:"
  puts "First: #{shadow_pct1}%"
  puts "Second: #{shadow_pct2}%"
  puts "Third: #{shadow_pct3}%"

  if shadow_pct3 > shadow_pct2 && shadow_pct2 > shadow_pct1
    puts "\nPROGRESSIVE REJECTION"
    puts "Each candle shows more selling pressure"
    puts "Clear exhaustion pattern"
  end

  # Calculate rejection zone
  rejection_high = high[-1]
  rejection_zone = rejection_high - close[-1]

  puts "\nRejection Zone:"
  puts "High: $#{rejection_high.round(2)}"
  puts "Close: $#{close[-1].round(2)}"
  puts "Rejection: $#{rejection_zone.round(2)} (#{(rejection_zone/close[-1]*100).round(2)}%)"

  if rejection_zone > (close[-1] - open[-1]) * 0.5
    puts "Large rejection zone - strong selling pressure above"
  end

  # Identify resistance
  if shadow_pct3 > 40
    puts "\nThird candle rejected >40% of range"
    puts "Strong resistance at $#{rejection_high.round(2)}"
    puts "Risk/reward poor for new longs"
  end
end
```

## Trading Strategies

### Entry Rules

#### Conservative Entry (Recommended)
```ruby
# Wait for confirmation candle
if pattern[-2] == -100  # Pattern 2 candles ago
  # Look for bearish confirmation
  if close[-1] < open[-1] && close.last < close[-1]
    puts "Advance Block CONFIRMED with bearish follow-through"
    entry = close.last

    puts "Enter SHORT at #{entry.round(2)}"
    puts "Pattern confirmed by declining prices"

    # Can also exit longs here
    puts "Consider closing long positions"
  end
end
```

#### Aggressive Entry
```ruby
# Enter on pattern completion
if pattern.last == -100
  entry = close.last

  puts "Advance Block completed"
  puts "Enter SHORT (aggressive) at #{entry.round(2)}"
  puts "Or exit long positions immediately"
  puts "Stop above pattern high"
end
```

#### Long Position Protection
```ruby
# Close longs on warning
if pattern.last == -100
  puts "Advance Block warning - Protect long positions"

  # Tighten stop on existing longs
  pattern_high = [high[-3], high[-2], high[-1]].max
  trailing_stop = pattern_high

  puts "Tighten stop to: #{trailing_stop.round(2)}"
  puts "Or close position and wait for clarity"

  # Alternative: Scale out
  puts "\nOr scale out of position:"
  puts "- Close 50% now"
  puts "- Trail stop on remaining 50%"
end
```

### Stop Loss Placement

```ruby
if pattern.last == -100
  # Stop above pattern high
  pattern_high = [high[-3], high[-2], high[-1]].max
  stop = pattern_high * 1.01  # 1% buffer

  entry = close.last
  risk = stop - entry
  risk_pct = (risk / entry * 100).round(2)

  puts "Stop loss: #{stop.round(2)}"
  puts "Above pattern high (invalidation point)"
  puts "Risk: $#{risk.round(2)} (#{risk_pct}%)"

  # Alternative: Above highest rejection
  highest_rejection = high[-1]
  tight_stop = highest_rejection * 1.005

  puts "\nTighter stop: #{tight_stop.round(2)}"
  puts "(Above third candle high)"
end
```

### Profit Targets

```ruby
if pattern.last == -100
  entry = close.last
  pattern_high = [high[-3], high[-2], high[-1]].max
  stop = pattern_high * 1.01
  risk = stop - entry

  # Risk-based targets
  target_1 = entry - (risk * 2)
  target_2 = entry - (risk * 3)
  target_3 = entry - (risk * 4)

  puts "Short Targets (from #{entry.round(2)}):"
  puts "T1 (2R): #{target_1.round(2)}"
  puts "T2 (3R): #{target_2.round(2)}"
  puts "T3 (4R): #{target_3.round(2)}"

  # Technical targets
  support_1 = close[-20..-4].min
  body_low = low[-3]

  puts "\nTechnical Targets:"
  puts "Pattern base: #{body_low.round(2)}"
  puts "Recent support: #{support_1.round(2)}"

  # Pattern height projection
  pattern_height = pattern_high - body_low
  measured_target = body_low - pattern_height

  puts "Measured move: #{measured_target.round(2)}"
end
```

## Example: Complete Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('GOOGL')

pattern = SQA::TAI.cdl_advanceblock(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_20 = SQA::TAI.sma(close, period: 20)
sma_50 = SQA::TAI.sma(close, period: 50)

if pattern.last == -100
  puts "Advance Block Pattern Analysis"
  puts "=" * 60

  # 1. Trend context
  uptrend = close[-4] > sma_20[-4] && sma_20[-4] > sma_50[-4]
  extended = close[-4] > close[-15]
  context_score = uptrend && extended

  # 2. Body progression
  body1 = (close[-3] - open[-3]).abs
  body2 = (close[-2] - open[-2]).abs
  body3 = (close[-1] - open[-1]).abs

  decreasing_bodies = body1 > body2 && body2 > body3
  significant_decrease = body3 < body1 * 0.5

  # 3. Shadow progression
  shadow1 = high[-3] - close[-3]
  shadow2 = high[-2] - close[-2]
  shadow3 = high[-1] - close[-1]

  increasing_shadows = shadow1 < shadow2 && shadow2 < shadow3
  long_third_shadow = shadow3 > (close[-1] - open[-1]) * 0.3

  # 4. Volume decline
  vol1, vol2, vol3 = volume[-3], volume[-2], volume[-1]
  avg_vol = volume[-20..-4].sum / 17.0

  declining_volume = vol1 > vol2 && vol2 > vol3
  weak_final_vol = vol3 < avg_vol

  # 5. RSI condition
  overbought = rsi[-4] > 70
  divergence = close[-1] > close[-5] && rsi[-1] < rsi[-5]

  # 6. Resistance
  resistance = close[-30..-4].max
  near_resistance = close[-1] >= resistance * 0.98

  # Calculate quality score
  score = 0
  score += 2 if context_score
  score += 3 if decreasing_bodies
  score += 2 if significant_decrease
  score += 3 if increasing_shadows
  score += 1 if long_third_shadow
  score += 2 if declining_volume
  score += 1 if weak_final_vol
  score += 2 if overbought
  score += 2 if divergence
  score += 2 if near_resistance

  puts "\nQuality Score: #{score}/20"

  if score >= 14
    entry = close.last
    pattern_high = [high[-3], high[-2], high[-1]].max
    stop = pattern_high * 1.01
    risk = stop - entry

    support = close[-30..-4].min
    target = support
    reward = entry - target
    rr = (reward / risk).round(1)

    puts "\n*** STRONG REVERSAL WARNING ***"
    puts "Direction: SHORT (or close longs)"
    puts "Entry: $#{entry.round(2)}"
    puts "Stop: $#{stop.round(2)}"
    puts "Target: $#{target.round(2)}"
    puts "R:R: 1:#{rr}"
  end
end
```

## Pattern Statistics

### Frequency
- **Occurrence**: Uncommon (2-3% of uptrends)
- **Best Timeframes**: Daily and weekly charts
- **Markets**: Works on all markets

### Success Rate
- **Perfect pattern**: 72-78% reversal rate
- **Good pattern**: 62-72% reversal rate
- **With volume decline**: 70-80% success
- **At resistance**: 75-82% success

### Average Move
- **Initial decline**: 8-15% from pattern high
- **Major reversals**: 20-35% decline
- **Time to target**: 10-25 candles

## Best Practices

### Do's
1. Verify clear uptrend before pattern
2. Confirm diminishing body sizes
3. Look for increasing upper shadows
4. Check for declining volume
5. Wait for bearish confirmation if unsure
6. Use pattern to protect long positions
7. Combine with overbought RSI
8. Look for pattern at resistance
9. Measure momentum decline
10. Monitor for early reversal signs

### Don'ts
1. Don't trade without uptrend context
2. Don't ignore body size progression
3. Don't overlook shadow analysis
4. Don't skip volume confirmation
5. Don't use in choppy markets
6. Don't trade with increasing volume
7. Don't ignore if bodies grow larger
8. Don't confuse with Three White Soldiers
9. Don't chase if already reversed
10. Don't ignore resistance levels

## Common Mistakes

1. **Misidentification**: Must have three white candles with decreasing bodies
2. **Ignoring progression**: Bodies must get progressively smaller
3. **Wrong trend context**: Needs clear uptrend
4. **Ignoring shadows**: Upper shadows must lengthen
5. **Volume oversight**: Declining volume confirms pattern
6. **No confirmation**: Better to wait for bearish follow-through
7. **Confusing patterns**: Not same as Three Advancing White Soldiers

## Related Patterns

### Similar Patterns
- [Stalled Pattern](cdl_stalledpattern.md) - Similar exhaustion pattern
- [Three White Soldiers](cdl_3whitesoldiers.md) - Bullish version
- [Evening Star](cdl_eveningstar.md) - Another bearish reversal

### Component Patterns
- [Long Line](cdl_longline.md) - First candle characteristics
- [Short Line](cdl_shortline.md) - Third candle characteristics

## Key Takeaways

1. **Warning signal** - not immediate reversal
2. **Progressive weakening** - each candle shows less strength
3. **Body decrease critical** - must see diminishing bodies
4. **Shadow increase important** - shows rejection
5. **Volume confirms** - declining volume validates pattern
6. **Protect longs** - time to tighten stops
7. **Wait for confirmation** - pattern shows warning, not certainty
8. **Resistance matters** - more reliable at resistance
9. **Combine indicators** - use with RSI, volume, support/resistance
10. **Early warning** - gives time to prepare for reversal

## See Also

- [Stalled Pattern](cdl_stalledpattern.md)
- [Three White Soldiers](cdl_3whitesoldiers.md)
- [Evening Star](cdl_eveningstar.md)
- [Dark Cloud Cover](cdl_darkcloudcover.md)
- [Pattern Recognition Overview](index.md)
- [Back to Indicators](../index.md)
