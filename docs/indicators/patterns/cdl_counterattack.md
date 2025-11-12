# Counterattack Pattern

The Counterattack is a powerful two-candle reversal pattern that signals a sudden shift in market momentum. It occurs when the second candle opens at a significant gap but closes at or very near the previous candle's close, showing that the opposing force has "counterattacked" and neutralized the initial move. This pattern demonstrates a dramatic rejection of the trend direction.

## Pattern Type

- **Type**: Reversal (Bullish or Bearish)
- **Candles Required**: 2
- **Trend Context**: Requires established trend
- **Reliability**: High (strong reversal signal)
- **Frequency**: Uncommon (appears 2-4% of the time)

## Usage

```ruby
require 'sqa/tai'

# Bullish Counterattack example
open  = [95.0, 92.0, 88.0, 85.0, 92.0]
high  = [95.5, 92.5, 88.5, 85.5, 92.5]
low   = [91.0, 88.0, 84.0, 82.0, 84.5]
close = [92.0, 88.5, 85.0, 82.5, 85.0]

# Detect Counterattack pattern
pattern = SQA::TAI.cdl_counterattack(open, high, low, close)

if pattern.last == 100
  puts "Bullish Counterattack - Strong reversal signal!"
elsif pattern.last == -100
  puts "Bearish Counterattack - Topping pattern!"
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
- **0**: No Counterattack pattern detected
- **+100**: Bullish Counterattack pattern (bullish reversal signal)
- **-100**: Bearish Counterattack pattern (bearish reversal signal)

## Pattern Recognition Rules

### Bullish Counterattack (Bottom Reversal)

1. **First Candle**: Long bearish candle in downtrend
   - Strong selling pressure
   - Continues the prevailing downtrend
   - Large real body (significant price decline)

2. **Second Candle**: Bullish candle with specific characteristics
   - Opens significantly LOWER (gap down)
   - Shows initial continuation of bearish sentiment
   - Rallies strongly during the session
   - Closes at or very near the first candle's close
   - Creates a "counterattack" against the downtrend

### Bearish Counterattack (Top Reversal)

1. **First Candle**: Long bullish candle in uptrend
   - Strong buying pressure
   - Continues the prevailing uptrend
   - Large real body (significant price advance)

2. **Second Candle**: Bearish candle with specific characteristics
   - Opens significantly HIGHER (gap up)
   - Shows initial continuation of bullish sentiment
   - Declines strongly during the session
   - Closes at or very near the first candle's close
   - Creates a "counterattack" against the uptrend

### Key Characteristics

- **Gap opening**: Second candle must open with a gap
- **Close alignment**: Closes must be very close (within 0.1-0.3%)
- **Strong reversal**: Second candle shows powerful reversal
- **Trend negation**: Gap is filled by close
- **Momentum shift**: Shows sudden change in control
- **Large bodies**: Both candles should have substantial bodies
- **Psychological impact**: Gap opening shakes out weak hands

### Ideal Pattern Features

- **Large gap**: Second candle opens with significant gap
- **Exact close match**: Closes align perfectly
- **Long candles**: Both candles have long real bodies
- **Volume surge**: High volume on reversal candle
- **Trend context**: Clear established trend before pattern
- **Support/Resistance**: Forms at key technical levels
- **Follow-through**: Next candle confirms reversal

## Visual Pattern

```
Bullish Counterattack (Bottom):

                        Second: Opens lower,
         [====]         closes at first's close
          |   |         (counterattack!)
          |   |
    [=====]             First: Long bearish
     |    |             (downtrend)

Bears attempt continuation via gap down,
but bulls counterattack and close at same level


Bearish Counterattack (Top):

    [=====]             First: Long bullish
     |    |             (uptrend)
          |   |
          |   |
         [====]         Second: Opens higher,
                        closes at first's close
                        (counterattack!)

Bulls attempt continuation via gap up,
but bears counterattack and close at same level
```

## Interpretation

The Counterattack pattern signals reversal through:

1. **Gap deception**: Opening gap suggests continuation
2. **Momentum reversal**: Strong move back to previous close
3. **Failed breakout**: Gap gets completely filled
4. **Sentiment shift**: Initial direction is rejected
5. **Battle of forces**: Shows conflict between bulls/bears
6. **Line in sand**: Previous close becomes key level
7. **Psychological impact**: Traps traders on wrong side

### Reliability Factors

| Factor | Low Reliability | Medium Reliability | High Reliability |
|--------|----------------|-------------------|------------------|
| Trend Strength | Weak trend | Clear trend | Strong/extended trend |
| Gap Size | Small gap | Medium gap | Large gap |
| Close Match | >0.5% apart | 0.2-0.5% apart | <0.2% apart |
| Candle Size | Small bodies | Medium bodies | Long bodies |
| Volume | Low/normal | Increasing | High spike on 2nd |
| Technical Level | Random | Near S/R | At major S/R |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Example: Bullish Counterattack at Bottom

```ruby
open, high, low, close = load_ohlc_data('AAPL')

pattern = SQA::TAI.cdl_counterattack(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last == 100
  puts "Bullish Counterattack detected!"

  # Verify downtrend context
  downtrend = close[-3] < sma_50[-3] &&
              close[-5] > close[-3]

  # Measure gap
  gap_size = open[-1] - close[-2]
  gap_pct = (gap_size.abs / close[-2] * 100).round(2)

  # Measure close alignment
  close_diff = (close[-1] - close[-2]).abs
  close_diff_pct = (close_diff / close[-2] * 100).round(2)

  puts "\nPattern Analysis:"
  puts "Gap down: #{gap_pct}%"
  puts "Close difference: #{close_diff_pct}%"

  if close_diff_pct < 0.3
    puts "EXCELLENT close alignment!"
  elsif close_diff_pct < 0.5
    puts "Good close alignment"
  else
    puts "Fair close alignment"
  end

  # Check candle sizes
  body1 = (close[-2] - open[-2]).abs
  body2 = (close[-1] - open[-1]).abs
  avg_range = (high[-10..-3] - low[-10..-3]).sum / 8.0

  strong_candles = body1 > avg_range * 0.6 &&
                   body2 > avg_range * 0.6

  if downtrend && gap_pct > 1.0 &&
     close_diff_pct < 0.3 && strong_candles
    puts "\n*** TEXTBOOK BULLISH COUNTERATTACK ***"
    puts "Bears tried to continue via gap"
    puts "Bulls counterattacked strongly"
    puts "RSI: #{rsi.last.round(2)}"

    if rsi.last < 35
      puts "OVERSOLD + Counterattack = STRONG signal"
    end
  end
end
```

## Example: Bearish Counterattack at Top

```ruby
open, high, low, close = load_ohlc_data('TSLA')

pattern = SQA::TAI.cdl_counterattack(open, high, low, close)
sma_20 = SQA::TAI.sma(close, period: 20)
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last == -100
  puts "Bearish Counterattack detected!"

  # Verify uptrend context
  uptrend = close[-3] > sma_20[-3] &&
            close[-3] > close[-5]

  # Measure gap
  gap_size = open[-1] - close[-2]
  gap_pct = (gap_size / close[-2] * 100).round(2)

  # Measure close alignment
  close_diff = (close[-1] - close[-2]).abs
  close_diff_pct = (close_diff / close[-2] * 100).round(2)

  puts "\nPattern Analysis:"
  puts "Gap up: #{gap_pct}%"
  puts "Close difference: #{close_diff_pct}%"

  # Check for distribution
  if close_diff_pct < 0.3 && gap_pct > 1.0
    puts "\nPERFECT BEARISH COUNTERATTACK"
    puts "Bulls gapped up (strength)"
    puts "Bears counterattacked (closed at same level)"
    puts "Gap filled completely!"

    if rsi[-2] > 70
      puts "\nFormed in OVERBOUGHT territory"
      puts "Very strong reversal signal"
    end
  end

  if uptrend && gap_pct > 1.0 && close_diff_pct < 0.3
    puts "\n*** MAJOR TOPPING PATTERN ***"
    puts "Consider protective stops on longs"

    # Estimate potential decline
    recent_support = close[-20..-1].min
    potential_decline = ((close.last - recent_support) / close.last * 100).round(2)
    puts "Potential decline to support: #{potential_decline}%"
  end
end
```

## Example: Volume Confirmation

```ruby
open, high, low, close, volume = load_ohlc_volume_data('NVDA')

pattern = SQA::TAI.cdl_counterattack(open, high, low, close)

if pattern.last != 0
  direction = pattern.last > 0 ? "BULLISH" : "BEARISH"
  puts "#{direction} Counterattack detected"

  # Analyze volume pattern
  vol1 = volume[-2]  # First candle
  vol2 = volume[-1]  # Counterattack candle
  avg_vol = volume[-20..-3].sum / 18.0

  puts "\nVolume Analysis:"
  puts "First candle: #{vol1.round(0)} (#{(vol1/avg_vol).round(2)}x avg)"
  puts "Counterattack: #{vol2.round(0)} (#{(vol2/avg_vol).round(2)}x avg)"

  # Ideal: high volume on counterattack
  high_counterattack_vol = vol2 > avg_vol * 1.5

  if high_counterattack_vol
    puts "\nEXCELLENT: High volume on counterattack"
    puts "Shows strong conviction in reversal"
    puts "Pattern much more reliable"
  elsif vol2 > avg_vol
    puts "\nGOOD: Above average volume"
    puts "Decent conviction"
  else
    puts "\nWARNING: Low volume"
    puts "Pattern less reliable"
  end

  # Volume ratio
  vol_ratio = vol2 / vol1
  if vol_ratio > 1.3
    puts "\nCounterattack volume > First candle"
    puts "Very strong reversal conviction"
  end
end
```

## Example: Close Alignment Analysis

```ruby
open, high, low, close = load_ohlc_data('MSFT')

pattern = SQA::TAI.cdl_counterattack(open, high, low, close)

if pattern.last != 0
  direction = pattern.last > 0 ? "Bullish" : "Bearish"
  puts "#{direction} Counterattack - Close Analysis"

  # Measure how closely the closes align
  close1 = close[-2]
  close2 = close[-1]
  diff = (close2 - close1).abs
  diff_pct = (diff / close1 * 100).round(3)

  puts "\nClose Alignment:"
  puts "First close: $#{close1.round(2)}"
  puts "Second close: $#{close2.round(2)}"
  puts "Difference: $#{diff.round(2)} (#{diff_pct}%)"

  # Grade the alignment
  if diff_pct < 0.1
    grade = "PERFECT"
    score = 10
  elsif diff_pct < 0.2
    grade = "EXCELLENT"
    score = 9
  elsif diff_pct < 0.3
    grade = "VERY GOOD"
    score = 8
  elsif diff_pct < 0.5
    grade = "GOOD"
    score = 7
  elsif diff_pct < 0.8
    grade = "FAIR"
    score = 6
  else
    grade = "POOR"
    score = 4
  end

  puts "\nAlignment Grade: #{grade} (#{score}/10)"

  # Check gap size
  if pattern.last > 0
    gap = close1 - open[-1]  # Gap down
  else
    gap = open[-1] - close1  # Gap up
  end

  gap_pct = (gap / close1 * 100).round(2)
  puts "\nGap size: #{gap_pct}%"

  if gap_pct > 2.0 && diff_pct < 0.3
    puts "\n*** TEXTBOOK COUNTERATTACK ***"
    puts "Large gap + Perfect close alignment"
    puts "Extremely reliable pattern"
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
    # Confirm with follow-through
    if close[-1] > close[-2] && close.last > close[-1]
      puts "Bullish Counterattack CONFIRMED"
      entry = close.last
      puts "Enter LONG at #{entry.round(2)}"
    end
  else  # Bearish
    # Confirm with follow-through
    if close[-1] < close[-2] && close.last < close[-1]
      puts "Bearish Counterattack CONFIRMED"
      entry = close.last
      puts "Enter SHORT at #{entry.round(2)}"
    end
  end
end
```

#### Aggressive Entry
```ruby
# Enter on pattern completion
if pattern.last != 0
  direction = pattern.last > 0 ? "LONG" : "SHORT"
  entry = close.last

  # Verify close alignment
  close_diff = (close[-1] - close[-2]).abs
  close_diff_pct = close_diff / close[-2] * 100

  if close_diff_pct < 0.5
    puts "Counterattack completed - Enter #{direction}"
    puts "Entry: #{entry.round(2)}"
    puts "Close alignment: #{close_diff_pct.round(2)}%"
  else
    puts "WARNING: Poor close alignment (#{close_diff_pct.round(2)}%)"
    puts "Consider waiting for confirmation"
  end
end
```

#### Breakout Entry
```ruby
# Enter on break of pattern high/low
if pattern[-1] != 0
  if pattern[-1] > 0  # Bullish
    pattern_high = [high[-2], high[-1]].max

    if close.last > pattern_high
      puts "Bullish breakout above Counterattack"
      puts "Entry: #{close.last.round(2)}"
      puts "Pattern confirmed by breakout"
    end
  else  # Bearish
    pattern_low = [low[-2], low[-1]].min

    if close.last < pattern_low
      puts "Bearish breakdown below Counterattack"
      puts "Entry: #{close.last.round(2)}"
      puts "Pattern confirmed by breakdown"
    end
  end
end
```

### Stop Loss Placement

```ruby
if pattern.last != 0
  if pattern.last > 0  # Bullish
    # Stop below pattern low
    pattern_low = [low[-2], low[-1]].min
    stop = pattern_low * 0.99  # 1% buffer

    puts "Stop loss: #{stop.round(2)}"
    puts "Below pattern low (invalidation point)"

    # Alternative: stop below counterattack close
    alt_stop = (close[-1] - (close[-1] * 0.015)).round(2)
    puts "Alternative stop: #{alt_stop} (1.5% below close)"

  else  # Bearish
    # Stop above pattern high
    pattern_high = [high[-2], high[-1]].max
    stop = pattern_high * 1.01  # 1% buffer

    puts "Stop loss: #{stop.round(2)}"
    puts "Above pattern high (invalidation point)"

    # Alternative: stop above counterattack close
    alt_stop = (close[-1] + (close[-1] * 0.015)).round(2)
    puts "Alternative stop: #{alt_stop} (1.5% above close)"
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
    pattern_low = [low[-2], low[-1]].min
    stop = pattern_low * 0.99
    risk = entry - stop

    # Risk-based targets
    target_1 = entry + (risk * 2)
    target_2 = entry + (risk * 3)
    target_3 = entry + (risk * 5)

    puts "Bullish Targets:"
    puts "T1 (2R): #{target_1.round(2)}"
    puts "T2 (3R): #{target_2.round(2)}"
    puts "T3 (5R): #{target_3.round(2)}"

    # Technical targets
    resistance = close[-30..-1].max
    puts "\nResistance: #{resistance.round(2)}"

    # Pattern-based target (gap fill)
    if open[-2] > close[-2]  # Was gap down
      gap_top = open[-2]
      puts "Gap fill target: #{gap_top.round(2)}"
    end

  else  # Bearish
    pattern_high = [high[-2], high[-1]].max
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
    support = close[-30..-1].min
    puts "\nSupport: #{support.round(2)}"

    # Pattern-based target (gap fill)
    if open[-2] < close[-2]  # Was gap up
      gap_bottom = open[-2]
      puts "Gap fill target: #{gap_bottom.round(2)}"
    end
  end
end
```

## Example: Complete Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('GOOGL')

pattern = SQA::TAI.cdl_counterattack(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_20 = SQA::TAI.sma(close, period: 20)
sma_50 = SQA::TAI.sma(close, period: 50)

if pattern.last != 0
  direction = pattern.last > 0 ? "BULLISH" : "BEARISH"

  puts "#{direction} Counterattack Pattern Analysis"
  puts "=" * 60

  # 1. Trend context
  if pattern.last > 0
    downtrend = close[-3] < sma_20[-3] && sma_20[-3] < sma_50[-3]
    extended = close[-10] > close[-3]
    context_score = downtrend && extended
  else
    uptrend = close[-3] > sma_20[-3] && sma_20[-3] > sma_50[-3]
    extended = close[-3] > close[-10]
    context_score = uptrend && extended
  end

  # 2. Gap quality
  if pattern.last > 0
    gap = close[-2] - open[-1]
  else
    gap = open[-1] - close[-2]
  end
  gap_pct = (gap / close[-2] * 100).round(2)
  significant_gap = gap_pct > 1.0

  # 3. Close alignment
  close_diff = (close[-1] - close[-2]).abs
  close_diff_pct = (close_diff / close[-2] * 100).round(3)
  excellent_alignment = close_diff_pct < 0.3

  # 4. Candle size
  body1 = (close[-2] - open[-2]).abs
  body2 = (close[-1] - open[-1]).abs
  avg_range = (high[-10..-3] - low[-10..-3]).sum / 8.0
  strong_candles = body1 > avg_range * 0.5 && body2 > avg_range * 0.5

  # 5. Volume
  vol1, vol2 = volume[-2], volume[-1]
  avg_vol = volume[-20..-3].sum / 18.0
  high_counterattack_vol = vol2 > avg_vol * 1.3

  # 6. RSI extreme
  if pattern.last > 0
    extreme = rsi[-2] < 35
  else
    extreme = rsi[-2] > 65
  end

  # Calculate quality score
  score = 0
  score += 3 if context_score          # Critical
  score += 2 if significant_gap        # Very important
  score += 3 if excellent_alignment    # Critical
  score += 2 if strong_candles         # Very important
  score += 2 if high_counterattack_vol # Important
  score += 2 if extreme                # Important

  puts "\nQuality Checks:"
  puts "1. Trend context: #{context_score} #{context_score ? '✓✓✓' : '✗'}"
  puts "2. Significant gap (#{gap_pct}%): #{significant_gap} #{significant_gap ? '✓✓' : '✗'}"
  puts "3. Close alignment (#{close_diff_pct}%): #{excellent_alignment} #{excellent_alignment ? '✓✓✓' : '✗'}"
  puts "4. Strong candles: #{strong_candles} #{strong_candles ? '✓✓' : '✗'}"
  puts "5. High volume: #{high_counterattack_vol} #{high_counterattack_vol ? '✓✓' : '✗'}"
  puts "6. RSI extreme: #{extreme} #{extreme ? '✓✓' : '✗'}"
  puts "\nTotal Score: #{score}/14"

  if score >= 10
    # Calculate trade
    entry = close.last

    if pattern.last > 0
      pattern_low = [low[-2], low[-1]].min
      stop = pattern_low * 0.99
      risk = entry - stop
      resistance = close[-40..-1].max
      target = resistance
      reward = target - entry
    else
      pattern_high = [high[-2], high[-1]].max
      stop = pattern_high * 1.01
      risk = stop - entry
      support = close[-40..-1].min
      target = support
      reward = entry - target
    end

    rr = (reward / risk).round(1)

    puts "\n*** EXCELLENT SETUP ***"
    puts "-" * 60
    puts "Direction: #{direction}"
    puts "Entry: $#{entry.round(2)}"
    puts "Stop: $#{stop.round(2)}"
    puts "Target: $#{target.round(2)}"
    puts "Risk: $#{risk.round(2)} (#{(risk/entry*100).round(2)}%)"
    puts "Reward: $#{reward.round(2)} (#{(reward/entry*100).round(2)}%)"
    puts "R:R: 1:#{rr}"

    # Position sizing
    account = 100000
    risk_amount = account * 0.02  # 2% risk
    shares = (risk_amount / risk).floor

    puts "\nPosition Sizing (2% risk):"
    puts "Shares: #{shares}"
    puts "Position: $#{(shares * entry).round(2)}"
    puts "Risk: $#{risk_amount.round(2)}"
    puts "Potential profit: $#{(shares * reward).round(2)}"

  elsif score >= 7
    puts "\nGOOD SETUP - Consider trading"
    puts "Decent pattern quality"

  else
    puts "\nWEAK SETUP - Pattern incomplete"
    puts "Missing critical elements"
  end
end
```

## Pattern Statistics

### Frequency
- **Occurrence**: Uncommon (2-4% of patterns)
- **Best Timeframes**: Daily and 4-hour charts (most reliable)
- **Markets**: All markets, especially liquid stocks

### Success Rate
- **Perfect pattern**: 78-85% success rate
- **Good pattern**: 68-78% success rate
- **Average pattern**: 58-68% success rate
- **With volume**: 75-82% success rate
- **At major S/R**: 80-88% success rate
- **RSI extreme**: 76-84% success rate

### Average Move
- **Initial reversal**: 8-15% from pattern
- **Major reversals**: 20-40% move
- **Time to target**: 10-25 candles
- **Follow-through**: 72% show continuation

## Best Practices

### Do's
1. Verify strong trend before pattern
2. Measure gap size (larger is better)
3. Check close alignment (tighter is better)
4. Confirm with volume on counterattack
5. Use at major support/resistance
6. Check RSI for extreme readings
7. Wait for confirmation on weaker patterns
8. Consider candle body sizes
9. Combine with other indicators
10. Set stops beyond pattern extremes

### Don'ts
1. Don't trade without clear trend
2. Don't accept small gaps
3. Don't ignore close alignment quality
4. Don't trade on low volume
5. Don't use in ranging markets
6. Don't ignore RSI levels
7. Don't chase after several candles
8. Don't use tight stops
9. Don't trade every occurrence
10. Don't ignore follow-through action

## Common Mistakes

1. **Poor close alignment**: Closes must be very close
2. **Insufficient gap**: Gap must be significant
3. **Wrong trend context**: Needs established trend
4. **Ignoring volume**: Volume confirms conviction
5. **Weak candles**: Bodies should be substantial
6. **No confirmation**: Wait for follow-through on weaker setups
7. **Bad stop placement**: Must protect pattern structure

## Related Patterns

### Similar Patterns
- [Piercing Pattern](cdl_piercing.md) - Bullish reversal, different structure
- [Dark Cloud Cover](cdl_darkcloudcover.md) - Bearish reversal, different structure
- [Engulfing](cdl_engulfing.md) - Reversal with engulfing action
- [Meeting Lines](cdl_meetinglines.md) - Very similar pattern concept

### Component Patterns
- [Long Line](cdl_longline.md) - First candle characteristics
- [Marubozu](cdl_marubozu.md) - Ideal candle types

## Pattern Variations

### Perfect Counterattack
- Extended trend before pattern
- Gap > 1.5%
- Closes within 0.2%
- Long bodies on both candles
- High volume on counterattack
- At major support/resistance
- RSI extreme
- **Success Rate**: 82-88%

### Good Counterattack
- Clear trend context
- Gap > 0.8%
- Closes within 0.5%
- Medium-large bodies
- Above average volume
- **Success Rate**: 70-78%

### Weak Counterattack
- Unclear trend
- Small gap
- Closes > 0.5% apart
- Small candle bodies
- Low volume
- **Success Rate**: 55-65%

## Advanced Concepts

### Pattern Quality Scorer

```ruby
def score_counterattack(open, high, low, close, volume)
  return 0 if pattern.last == 0

  score = 0
  direction = pattern.last > 0 ? 1 : -1

  # Gap quality (0-3 points)
  if direction > 0
    gap = close[-2] - open[-1]
  else
    gap = open[-1] - close[-2]
  end
  gap_pct = (gap / close[-2] * 100).abs

  score += 3 if gap_pct > 2.0
  score += 2 if gap_pct > 1.0
  score += 1 if gap_pct > 0.5

  # Close alignment (0-4 points)
  close_diff = (close[-1] - close[-2]).abs
  close_diff_pct = (close_diff / close[-2] * 100)

  score += 4 if close_diff_pct < 0.1
  score += 3 if close_diff_pct < 0.2
  score += 2 if close_diff_pct < 0.3
  score += 1 if close_diff_pct < 0.5

  # Candle strength (0-2 points)
  body1 = (close[-2] - open[-2]).abs
  body2 = (close[-1] - open[-1]).abs
  avg_range = (high[-10..-3] - low[-10..-3]).sum / 8.0

  score += 2 if body1 > avg_range * 0.7 && body2 > avg_range * 0.7
  score += 1 if body1 > avg_range * 0.5 && body2 > avg_range * 0.5

  # Volume (0-2 points)
  avg_vol = volume[-20..-3].sum / 18.0
  score += 2 if volume[-1] > avg_vol * 1.5
  score += 1 if volume[-1] > avg_vol * 1.2

  score  # 0-11
end
```

## Key Takeaways

1. **Gap opening** - Second candle must gap in trend direction
2. **Close alignment** - Closes must be very close together
3. **Counterattack** - Second candle reverses and closes at first's close
4. **Strong candles** - Both should have substantial bodies
5. **Volume confirmation** - High volume on counterattack is ideal
6. **Trend context** - Requires established trend
7. **Psychological** - Traps traders expecting continuation
8. **Failed breakout** - Gap gets filled completely
9. **Reliability** - Strong pattern when properly formed
10. **Confirmation** - Follow-through strengthens signal

## See Also

- [Piercing Pattern](cdl_piercing.md) - Related bullish reversal
- [Dark Cloud Cover](cdl_darkcloudcover.md) - Related bearish reversal
- [Engulfing](cdl_engulfing.md) - Different reversal mechanism
- [Meeting Lines](cdl_meetinglines.md) - Similar close concept
- [Marubozu](cdl_marubozu.md) - Ideal candle type
- [Pattern Recognition Overview](index.md)
- [Back to Indicators](../index.md)
