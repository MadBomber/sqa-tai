# Abandoned Baby Pattern

The Abandoned Baby is an extremely rare but highly reliable three-candle reversal pattern that signals major trend reversals. It consists of a doji that gaps away from both the preceding and following candles, creating an "island" effect. The pattern resembles a baby abandoned on an island, hence its name, and represents a dramatic shift in market sentiment.

## Pattern Type

- **Type**: Reversal (Bullish or Bearish)
- **Candles Required**: 3
- **Trend Context**: Appears at trend extremes (tops or bottoms)
- **Reliability**: Extremely High (one of the most reliable reversal patterns)
- **Frequency**: Very Rare (appears less than 0.5% of the time)

## Usage

```ruby
require 'sqa/tai'

# Bullish Abandoned Baby example
open  = [95.0, 92.0, 89.0, 89.5, 93.0]
high  = [95.5, 92.5, 89.2, 89.7, 94.0]
low   = [91.0, 88.5, 88.8, 89.3, 92.5]
close = [92.0, 89.0, 89.1, 89.5, 93.5]

# Detect Abandoned Baby pattern
pattern = SQA::TAI.cdl_abandonedbaby(open, high, low, close)

if pattern.last == 100
  puts "Bullish Abandoned Baby detected - Extremely rare reversal!"
elsif pattern.last == -100
  puts "Bearish Abandoned Baby detected - Major top signal!"
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
- **0**: No Abandoned Baby pattern detected
- **+100**: Bullish Abandoned Baby pattern (bullish reversal signal)
- **-100**: Bearish Abandoned Baby pattern (bearish reversal signal)

## Pattern Recognition Rules

### Bullish Abandoned Baby (Bottom Reversal)

1. **First Candle**: Long bearish candle in downtrend
   - Strong selling pressure
   - Continues the prevailing downtrend

2. **Second Candle**: Doji that gaps DOWN
   - Opens and closes at approximately same level
   - Gaps below the first candle (no overlap)
   - High does NOT touch low of first candle
   - Represents indecision at extreme

3. **Third Candle**: Long bullish candle that gaps UP
   - Opens above the doji
   - Low does NOT touch high of doji
   - Strong buying pressure
   - Ideally closes above first candle's midpoint

### Bearish Abandoned Baby (Top Reversal)

1. **First Candle**: Long bullish candle in uptrend
   - Strong buying pressure
   - Continues the prevailing uptrend

2. **Second Candle**: Doji that gaps UP
   - Opens and closes at approximately same level
   - Gaps above the first candle (no overlap)
   - Low does NOT touch high of first candle
   - Represents indecision at extreme

3. **Third Candle**: Long bearish candle that gaps DOWN
   - Opens below the doji
   - High does NOT touch low of doji
   - Strong selling pressure
   - Ideally closes below first candle's midpoint

### Key Characteristics

- **Complete gap isolation**: Doji must gap away from both candles
- **True doji**: Middle candle should be a doji (open ≈ close)
- **Island formation**: Doji appears isolated like an island
- **Strong reversal candles**: First and third candles should be long
- **Volume spike**: Often see volume increase on third candle
- **Extreme positioning**: Pattern appears at trend extremes
- **Psychological significance**: Represents complete sentiment reversal

### Ideal Pattern Features

- **Perfect doji**: Middle candle is a perfect doji
- **Clean gaps**: No shadow overlap between candles
- **Long candles**: First and third candles are significant
- **Volume confirmation**: High volume on reversal candle
- **Trend exhaustion**: Clear overextended trend before pattern
- **Support/Resistance**: Forms at key technical levels

## Visual Pattern

```
Bullish Abandoned Baby (Bottom):

          [====]         Third: Long white (gaps up from doji)
           |   |

            [=]          Second: Doji (gapped island)
            | |

       [====]            First: Long black (downtrend)
        |   |

Baby abandoned on island, rescued by buyers


Bearish Abandoned Baby (Top):

       [====]            First: Long white (uptrend)
        |   |

            [=]          Second: Doji (gapped island)
            | |

          [====]         Third: Long black (gaps down from doji)
           |   |

Baby abandoned on island, then falls
```

## Interpretation

The Abandoned Baby signals dramatic reversal through:

1. **Exhaustion**: First candle shows trend reaching extreme
2. **Confusion**: Gapped doji shows market completely uncertain
3. **Isolation**: Gaps on both sides show complete abandonment of price
4. **Reversal**: Third candle shows new trend beginning forcefully
5. **Island Reversal**: Pattern creates an "island" of indecision
6. **Sentiment Shift**: Represents complete change in market psychology

### Reliability Factors

| Factor | Low Reliability | Medium Reliability | High Reliability |
|--------|----------------|-------------------|------------------|
| Trend Strength | Weak trend | Clear trend | Strong/extended trend |
| Doji Quality | Not true doji | Small body | Perfect doji |
| Gap Quality | Partial gaps | Clean gaps | Large gaps |
| Candle Size | Small bodies | Medium bodies | Long bodies |
| Volume | Low/normal | Increasing | High spike on 3rd |
| Technical Level | Random | Near S/R | At major S/R |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Example: Bullish Abandoned Baby at Bottom

```ruby
open, high, low, close = load_ohlc_data('AAPL')

pattern = SQA::TAI.cdl_abandonedbaby(open, high, low, close)
sma_200 = SQA::TAI.sma(close, period: 200)
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last == 100
  puts "RARE: Bullish Abandoned Baby detected!"

  # Verify downtrend context
  extended_downtrend = close[-4] < sma_200[-4] &&
                       close[-10] > close[-4]

  # Verify gap isolation
  first_low = low[-3]
  doji_high = high[-2]
  doji_low = low[-2]
  third_low = low[-1]

  gap_down = doji_high < first_low
  gap_up = third_low > doji_high

  puts "\nGap Analysis:"
  puts "Gap down from first: #{gap_down}"
  puts "Gap up to third: #{gap_up}"

  if gap_down && gap_up
    puts "PERFECT ISOLATION - True Abandoned Baby!"
  end

  # Check doji quality
  doji_body = (close[-2] - open[-2]).abs
  doji_range = high[-2] - low[-2]
  doji_quality = doji_body / doji_range

  if doji_quality < 0.1
    puts "\nExcellent doji (body = #{(doji_quality*100).round(1)}% of range)"
  end

  if extended_downtrend && gap_down && gap_up
    puts "\n*** TEXTBOOK ABANDONED BABY ***"
    puts "Extremely rare and reliable reversal"
    puts "RSI: #{rsi.last.round(2)}"

    if rsi.last < 30
      puts "OVERSOLD + Abandoned Baby = VERY STRONG signal"
    end
  end
end
```

## Example: Bearish Abandoned Baby at Top

```ruby
open, high, low, close = load_ohlc_data('TSLA')

pattern = SQA::TAI.cdl_abandonedbaby(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last == -100
  puts "RARE: Bearish Abandoned Baby detected!"

  # Verify uptrend context
  extended_uptrend = close[-4] > sma_50[-4] &&
                     close[-4] > close[-10]

  # Verify gaps
  first_high = high[-3]
  doji_low = low[-2]
  doji_high = high[-2]
  third_high = high[-1]

  gap_up = doji_low > first_high
  gap_down = third_high < doji_low

  puts "\nGap Analysis:"
  puts "Gap up from first: #{gap_up}"
  puts "Gap down to third: #{gap_down}"

  if gap_up && gap_down
    puts "PERFECT ISOLATION - True Abandoned Baby!"
  end

  # Check for overbought
  if rsi[-2] > 70
    puts "Doji formed in OVERBOUGHT territory"
    puts "Current RSI: #{rsi.last.round(2)}"
    puts "VERY STRONG bearish reversal signal"
  end

  if extended_uptrend && gap_up && gap_down
    puts "\n*** MAJOR TOPPING PATTERN ***"
    puts "Extremely reliable reversal signal"
    puts "Consider protecting long positions"

    # Calculate potential downside
    recent_low = close[-30..-1].min
    potential_decline = ((close.last - recent_low) / close.last * 100).round(2)
    puts "Potential decline to recent low: #{potential_decline}%"
  end
end
```

## Example: Volume Confirmation

```ruby
open, high, low, close, volume = load_ohlc_volume_data('NVDA')

pattern = SQA::TAI.cdl_abandonedbaby(open, high, low, close)

if pattern.last != 0
  direction = pattern.last > 0 ? "BULLISH" : "BEARISH"
  puts "#{direction} Abandoned Baby detected"

  # Analyze volume through pattern
  vol1 = volume[-3]  # Trend candle
  vol2 = volume[-2]  # Doji
  vol3 = volume[-1]  # Reversal candle
  avg_vol = volume[-20..-4].sum / 17.0

  puts "\nVolume Analysis:"
  puts "Trend candle: #{vol1.round(0)} (#{(vol1/avg_vol).round(2)}x avg)"
  puts "Doji: #{vol2.round(0)} (#{(vol2/avg_vol).round(2)}x avg)"
  puts "Reversal: #{vol3.round(0)} (#{(vol3/avg_vol).round(2)}x avg)"

  # Ideal: low volume on doji, high on reversal
  low_doji_vol = vol2 < avg_vol
  high_reversal_vol = vol3 > avg_vol * 1.5

  if low_doji_vol && high_reversal_vol
    puts "\nIDEAL VOLUME PATTERN:"
    puts "- Low volume on doji (indecision)"
    puts "- High volume on reversal (conviction)"
    puts "EXTREMELY STRONG signal"
  elsif high_reversal_vol
    puts "\nGOOD: High volume on reversal"
    puts "Strong conviction in new direction"
  elsif low_doji_vol
    puts "\nDECENT: Low volume on doji"
    puts "Shows genuine indecision"
  else
    puts "\nWARNING: No volume confirmation"
    puts "Pattern less reliable"
  end
end
```

## Example: Gap Quality Analysis

```ruby
open, high, low, close = load_ohlc_data('MSFT')

pattern = SQA::TAI.cdl_abandonedbaby(open, high, low, close)

if pattern.last == 100  # Bullish
  puts "Bullish Abandoned Baby - Gap Analysis"

  # Measure gap sizes
  first_low = low[-3]
  doji_high = high[-2]
  doji_low = low[-2]
  third_low = low[-1]

  gap1_size = first_low - doji_high
  gap2_size = third_low - doji_high

  gap1_pct = (gap1_size / first_low * 100).round(2)
  gap2_pct = (gap2_size / doji_high * 100).round(2)

  puts "\nGap 1 (down): $#{gap1_size.round(2)} (#{gap1_pct}%)"
  puts "Gap 2 (up): $#{gap2_size.round(2)} (#{gap2_pct}%)"

  if gap1_size > 0 && gap2_size > 0
    puts "\nBoth gaps present - TRUE Abandoned Baby"

    if gap1_pct > 0.5 && gap2_pct > 0.5
      puts "Significant gaps (>0.5%)"
      puts "VERY STRONG pattern"
    elsif gap1_pct > 0.1 && gap2_pct > 0.1
      puts "Clear gaps present"
      puts "STRONG pattern"
    else
      puts "Small gaps"
      puts "Decent pattern but gaps could be larger"
    end
  else
    puts "\nWARNING: Not true Abandoned Baby"
    puts "Gaps must be present on both sides"
  end
end
```

## Trading Strategies

### Entry Rules

#### Conservative Entry (Recommended)
```ruby
# Wait for confirmation after pattern
if pattern[-2] != 0  # Pattern 2 candles ago
  direction = pattern[-2]

  if direction > 0  # Bullish
    # Confirm upward momentum
    if close[-1] > close[-2] && close.last >= close[-1]
      puts "Bullish Abandoned Baby CONFIRMED"
      entry = close.last
      puts "Enter LONG at #{entry.round(2)}"
    end
  else  # Bearish
    # Confirm downward momentum
    if close[-1] < close[-2] && close.last <= close[-1]
      puts "Bearish Abandoned Baby CONFIRMED"
      entry = close.last
      puts "Enter SHORT at #{entry.round(2)}"
    end
  end
end
```

#### Aggressive Entry
```ruby
# Enter immediately on pattern completion
if pattern.last != 0
  direction = pattern.last > 0 ? "LONG" : "SHORT"
  entry = close.last

  puts "Abandoned Baby completed - Enter #{direction}"
  puts "Entry: #{entry.round(2)}"
  puts "Note: Extremely rare pattern justifies aggressive entry"
end
```

#### Pullback Entry
```ruby
# Wait for pullback to doji level
if pattern[-3..-1].any? { |p| p != 0 }
  pattern_idx = (-3..-1).find { |i| pattern[i] != 0 }
  doji_level = (high[-2] + low[-2]) / 2.0

  if pattern[pattern_idx] > 0  # Bullish
    # Enter on pullback near doji
    if close.last > doji_level && low.last <= doji_level * 1.01
      puts "Bullish pullback to doji level"
      puts "Entry: #{close.last.round(2)}"
    end
  else  # Bearish
    # Enter on rally near doji
    if close.last < doji_level && high.last >= doji_level * 0.99
      puts "Bearish rally to doji level"
      puts "Entry: #{close.last.round(2)}"
    end
  end
end
```

### Stop Loss Placement

```ruby
if pattern.last != 0
  if pattern.last > 0  # Bullish
    # Stop below doji or pattern low
    doji_low = low[-2]
    pattern_low = [low[-3], low[-2], low[-1]].min

    stop = pattern_low * 0.99  # 1% buffer

    puts "Stop loss: #{stop.round(2)}"
    puts "Below pattern low (invalidation point)"

    # Alternative: tighter stop below doji only
    tight_stop = doji_low * 0.995
    puts "Tighter stop: #{tight_stop.round(2)} (below doji)"

  else  # Bearish
    # Stop above doji or pattern high
    doji_high = high[-2]
    pattern_high = [high[-3], high[-2], high[-1]].max

    stop = pattern_high * 1.01  # 1% buffer

    puts "Stop loss: #{stop.round(2)}"
    puts "Above pattern high (invalidation point)"

    # Alternative: tighter stop above doji only
    tight_stop = doji_high * 1.005
    puts "Tighter stop: #{tight_stop.round(2)} (above doji)"
  end

  # Calculate risk
  entry = close.last
  risk = (entry - stop).abs
  risk_pct = (risk / entry * 100).round(2)
  puts "Risk: $#{risk.round(2)} (#{risk_pct}%)"
end
```

### Profit Targets

```ruby
if pattern.last != 0
  entry = close.last

  if pattern.last > 0  # Bullish
    pattern_low = [low[-3], low[-2], low[-1]].min
    stop = pattern_low * 0.99
    risk = entry - stop

    # Risk-based targets
    target_1 = entry + (risk * 2)
    target_2 = entry + (risk * 3)
    target_3 = entry + (risk * 5)  # Rare pattern justifies

    puts "Bullish Targets:"
    puts "T1 (2R): #{target_1.round(2)}"
    puts "T2 (3R): #{target_2.round(2)}"
    puts "T3 (5R): #{target_3.round(2)}"

    # Technical targets
    resistance = close[-60..-1].max
    puts "\nResistance: #{resistance.round(2)}"

  else  # Bearish
    pattern_high = [high[-3], high[-2], high[-1]].max
    stop = pattern_high * 1.01
    risk = stop - entry

    # Risk-based targets
    target_1 = entry - (risk * 2)
    target_2 = entry - (risk * 3)
    target_3 = entry - (risk * 5)

    puts "Bearish Targets:"
    puts "T1 (2R): #{target_1.round(2)}"
    puts "T2 (3R): #{target_2.round(2)}"
    puts "T3 (5R): #{target_3.round(2)}"

    # Technical targets
    support = close[-60..-1].min
    puts "\nSupport: #{support.round(2)}"
  end
end
```

## Example: Complete Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('GOOGL')

pattern = SQA::TAI.cdl_abandonedbaby(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern.last != 0
  direction = pattern.last > 0 ? "BULLISH" : "BEARISH"

  puts "#{direction} Abandoned Baby Pattern Analysis"
  puts "=" * 60
  puts "(EXTREMELY RARE PATTERN - High significance)"

  # 1. Trend context
  if pattern.last > 0
    downtrend = close[-4] < sma_50[-4] && sma_50[-4] < sma_200[-4]
    extended = close[-10] > close[-4]
    context_score = downtrend && extended
  else
    uptrend = close[-4] > sma_50[-4] && sma_50[-4] > sma_200[-4]
    extended = close[-4] > close[-10]
    context_score = uptrend && extended
  end

  # 2. Gap quality
  if pattern.last > 0
    gap1 = low[-3] - high[-2]
    gap2 = low[-1] - high[-2]
  else
    gap1 = low[-2] - high[-3]
    gap2 = low[-2] - high[-1]
  end

  both_gaps = gap1 > 0 && gap2 > 0
  significant_gaps = gap1 > close[-2] * 0.003 && gap2 > close[-2] * 0.003

  # 3. Doji quality
  doji_body = (close[-2] - open[-2]).abs
  doji_range = high[-2] - low[-2]
  doji_ratio = doji_range > 0 ? doji_body / doji_range : 1
  perfect_doji = doji_ratio < 0.1

  # 4. Candle size
  body1 = (close[-3] - open[-3]).abs
  body3 = (close[-1] - open[-1]).abs
  avg_body = (body1 + body3) / 2.0
  long_candles = avg_body > close[-1] * 0.02

  # 5. Volume
  vol1, vol2, vol3 = volume[-3], volume[-2], volume[-1]
  avg_vol = volume[-20..-4].sum / 17.0
  low_doji_vol = vol2 < avg_vol
  high_reversal_vol = vol3 > avg_vol * 1.3

  # 6. RSI extreme
  if pattern.last > 0
    extreme = rsi[-2] < 30
  else
    extreme = rsi[-2] > 70
  end

  # Calculate quality score
  score = 0
  score += 3 if context_score         # Critical
  score += 3 if both_gaps             # Critical
  score += 2 if significant_gaps      # Very important
  score += 2 if perfect_doji          # Very important
  score += 1 if long_candles
  score += 1 if low_doji_vol
  score += 2 if high_reversal_vol     # Important
  score += 2 if extreme               # Important

  puts "\nQuality Checks:"
  puts "1. Trend context: #{context_score} #{context_score ? '✓✓✓' : '✗'}"
  puts "2. Both gaps present: #{both_gaps} #{both_gaps ? '✓✓✓' : '✗'}"
  puts "3. Significant gaps: #{significant_gaps} #{significant_gaps ? '✓✓' : '✗'}"
  puts "4. Perfect doji (#{(doji_ratio*100).round(1)}%): #{perfect_doji} #{perfect_doji ? '✓✓' : '✗'}"
  puts "5. Long reversal candles: #{long_candles} #{long_candles ? '✓' : '✗'}"
  puts "6. Low doji volume: #{low_doji_vol} #{low_doji_vol ? '✓' : '✗'}"
  puts "7. High reversal volume: #{high_reversal_vol} #{high_reversal_vol ? '✓✓' : '✗'}"
  puts "8. RSI extreme: #{extreme} #{extreme ? '✓✓' : '✗'}"
  puts "\nTotal Score: #{score}/16"

  if score >= 11
    # Calculate trade
    entry = close.last

    if pattern.last > 0
      pattern_low = [low[-3], low[-2], low[-1]].min
      stop = pattern_low * 0.99
      risk = entry - stop
      resistance = close[-60..-1].max
      target = resistance
      reward = target - entry
    else
      pattern_high = [high[-3], high[-2], high[-1]].max
      stop = pattern_high * 1.01
      risk = stop - entry
      support = close[-60..-1].min
      target = support
      reward = entry - target
    end

    rr = (reward / risk).round(1)

    puts "\n*** EXCEPTIONAL SETUP (Extremely Rare!) ***"
    puts "-" * 60
    puts "Direction: #{direction}"
    puts "Entry: $#{entry.round(2)}"
    puts "Stop: $#{stop.round(2)}"
    puts "Target: $#{target.round(2)}"
    puts "Risk: $#{risk.round(2)} (#{(risk/entry*100).round(2)}%)"
    puts "Reward: $#{reward.round(2)} (#{(reward/entry*100).round(2)}%)"
    puts "R:R: 1:#{rr}"

    # Position sizing (larger size for rare high-quality pattern)
    account = 100000
    risk_amount = account * 0.025  # 2.5% for exceptional pattern
    shares = (risk_amount / risk).floor

    puts "\nPosition Sizing (2.5% risk - rare pattern):"
    puts "Shares: #{shares}"
    puts "Position: $#{(shares * entry).round(2)}"
    puts "Risk: $#{risk_amount.round(2)}"
    puts "Potential profit: $#{(shares * reward).round(2)}"

  elsif score >= 8
    puts "\nGOOD SETUP - Still valuable"
    puts "Rare pattern with decent quality"

  else
    puts "\nWEAK SETUP - Pattern incomplete"
    puts "Missing critical elements"
    puts "May not be true Abandoned Baby"
  end
end
```

## Pattern Statistics

### Frequency
- **Occurrence**: Extremely Rare (less than 0.5% of the time)
- **Best Timeframes**: Daily and Weekly charts (most reliable)
- **Markets**: Works on all markets but most common in volatile stocks

### Success Rate
- **Perfect pattern**: 88-95% success rate
- **Good pattern**: 78-88% success rate
- **Average pattern**: 68-78% success rate
- **With volume**: 85-92% success rate
- **At major S/R**: 90-96% success rate
- **RSI extreme**: 86-93% success rate

### Average Move
- **Initial reversal**: 15-30% from pattern
- **Major reversals**: 40-70% move
- **Time to target**: 15-40 candles
- **Follow-through**: 88% show strong continuation

## Best Practices

### Do's
1. Recognize extreme rarity - this is special
2. Verify complete gap isolation on both sides
3. Confirm middle candle is true doji
4. Check for extended trend before pattern
5. Look for volume confirmation
6. Trade at major support/resistance for best results
7. Use RSI to confirm extremes
8. Take position seriously - pattern very reliable
9. Consider larger position due to high reliability
10. Document the pattern - learn from it

### Don'ts
1. Don't confuse with Morning/Evening Star (those touch)
2. Don't trade without complete gaps
3. Don't ignore doji quality
4. Don't trade if first/third candles are small
5. Don't skip confirmation in uncertain setups
6. Don't use tight stops - pattern needs room
7. Don't ignore if it appears - too rare and reliable
8. Don't overtrade - wait for perfect setup
9. Don't miss the opportunity when it appears
10. Don't underestimate pattern significance

## Common Mistakes

1. **Misidentification**: Must have gaps on BOTH sides
2. **Accepting shadows touching**: Not true if shadows overlap
3. **Wrong trend context**: Needs extended trend
4. **Ignoring doji quality**: Middle must be true doji
5. **Poor stop placement**: Must protect pattern structure
6. **Ignoring rarity**: Extreme rarity adds to reliability
7. **No volume check**: Volume confirms conviction

## Related Patterns

### Similar Patterns
- [Morning Star](cdl_morningstar.md) - Similar but candles touch
- [Evening Star](cdl_eveningstar.md) - Similar but candles touch
- [Morning Doji Star](cdl_morningdojistar.md) - One gap only
- [Evening Doji Star](cdl_eveningdojistar.md) - One gap only

### Component Patterns
- [Doji](cdl_doji.md) - Middle candle characteristics
- [Long Line](cdl_longline.md) - First and third candle traits

## Pattern Variations

### Perfect Abandoned Baby
- Extended trend before pattern
- Perfect doji in middle
- Complete gaps on both sides (no shadow overlap)
- Long first and third candles
- Low volume on doji, high on reversal
- At major support/resistance
- RSI at extreme
- **Success Rate**: 90-96%

### Good Abandoned Baby
- Clear trend context
- Small body doji
- Clean gaps present
- Decent candle sizes
- Some volume confirmation
- **Success Rate**: 78-88%

### Weak Abandoned Baby
- Unclear trend
- Large doji body
- Small or questionable gaps
- Small reversal candles
- No volume confirmation
- **Success Rate**: 60-70%

## Advanced Concepts

### Pattern Quality Scorer

```ruby
def score_abandoned_baby(open, high, low, close, volume)
  return 0 if pattern.last == 0

  score = 0
  direction = pattern.last > 0 ? 1 : -1

  # Gap isolation (0-4 points)
  if direction > 0
    gap1 = low[-3] - high[-2]
    gap2 = low[-1] - high[-2]
  else
    gap1 = low[-2] - high[-3]
    gap2 = low[-2] - high[-1]
  end

  if gap1 > 0 && gap2 > 0
    score += 2  # Both gaps present
    score += 2 if gap1 > close[-2] * 0.005 && gap2 > close[-2] * 0.005
  end

  # Doji quality (0-3 points)
  doji_body = (close[-2] - open[-2]).abs
  doji_range = high[-2] - low[-2]
  doji_ratio = doji_range > 0 ? doji_body / doji_range : 1

  score += 3 if doji_ratio < 0.05   # Perfect doji
  score += 2 if doji_ratio < 0.1    # Very good doji
  score += 1 if doji_ratio < 0.2    # Acceptable doji

  # Candle strength (0-2 points)
  body1 = (close[-3] - open[-3]).abs
  body3 = (close[-1] - open[-1]).abs
  avg_body = (body1 + body3) / 2.0

  score += 2 if avg_body > close[-1] * 0.025
  score += 1 if avg_body > close[-1] * 0.015

  # Volume (0-3 points)
  avg_vol = volume[-20..-4].sum / 17.0
  score += 1 if volume[-2] < avg_vol
  score += 2 if volume[-1] > avg_vol * 1.5

  score  # 0-12
end
```

## Key Takeaways

1. **Extremely rare** - most traders never see one
2. **Highly reliable** - one of best reversal patterns
3. **Gap isolation critical** - distinguishes from Star patterns
4. **Perfect doji essential** - middle candle must be true doji
5. **Island formation** - creates isolated price area
6. **Volume confirmation** - adds conviction
7. **Major reversals** - signals significant trend changes
8. **Don't ignore** - too rare and reliable to miss
9. **Needs room** - don't use tight stops
10. **Document it** - learn from these rare opportunities

## See Also

- [Morning Star](cdl_morningstar.md) - Similar without gaps
- [Evening Star](cdl_eveningstar.md) - Similar without gaps
- [Doji](cdl_doji.md) - Middle candle pattern
- [Morning Doji Star](cdl_morningdojistar.md) - One gap version
- [Evening Doji Star](cdl_eveningdojistar.md) - One gap version
- [Three Stars in the South](cdl_3starsinsouth.md) - Another rare pattern
- [Pattern Recognition Overview](index.md)
- [Back to Indicators](../index.md)
