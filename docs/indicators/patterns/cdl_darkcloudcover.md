# Dark Cloud Cover Pattern

The Dark Cloud Cover is a powerful two-candle bearish reversal pattern that appears at the end of an uptrend. It consists of a long bullish candle followed by a bearish candle that opens above the first candle's high but closes more than halfway into the first candle's body. This pattern signals that bears have overwhelmed bulls and suggests a potential trend reversal from up to down.

## Pattern Type

- **Type**: Bearish Reversal
- **Candles Required**: 2
- **Trend Context**: Must appear in uptrend
- **Reliability**: High (strong reversal indicator)
- **Frequency**: Common (appears 4-6% of the time)

## Usage

```ruby
require 'sqa/tai'

# Dark Cloud Cover example
open  = [90.0, 94.0, 98.0, 102.0, 104.0]
high  = [90.5, 94.5, 98.5, 102.5, 105.0]
low   = [89.0, 93.0, 97.0, 101.0, 98.5]
close = [94.0, 98.0, 102.0, 103.5, 99.5]

# Detect Dark Cloud Cover pattern
pattern = SQA::TAI.cdl_darkcloudcover(open, high, low, close)

if pattern.last == -100
  puts "Dark Cloud Cover detected - Bearish reversal signal!"
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
- **0**: No Dark Cloud Cover pattern detected
- **-100**: Dark Cloud Cover pattern (bearish reversal signal)

Note: This is a bearish-only pattern. No positive values are returned.

## Pattern Recognition Rules

### Dark Cloud Cover Formation

1. **First Candle**: Long bullish (white/green) candle
   - Strong buying pressure
   - Part of existing uptrend
   - Large real body showing conviction
   - Ideally closes near its high

2. **Second Candle**: Bearish (black/red) candle with specific characteristics
   - Opens ABOVE the first candle's high (gap up)
   - Shows initial bullish continuation
   - Reverses and closes BELOW the midpoint of first candle's body
   - Demonstrates bear takeover during session
   - Does NOT close below first candle's low

### Key Characteristics

- **Gap up opening**: Second candle must gap above first
- **Penetration depth**: Must close >50% into first candle body
- **Body overlap**: Significant penetration but not full engulfing
- **Trend context**: Requires established uptrend
- **Psychological shift**: Bulls lose control to bears
- **Failed breakout**: Gap up fails completely
- **Distribution signal**: Often marks institutional selling

### Ideal Pattern Features

- **Strong uptrend**: Clear established uptrend before pattern
- **Gap opening**: Second candle gaps significantly higher
- **Deep penetration**: Close well below 50% mark (70%+ is ideal)
- **Long candles**: Both candles have substantial bodies
- **Volume surge**: High volume on second (bearish) candle
- **Resistance level**: Forms at key resistance
- **Equal lengths**: Both candles similar size
- **Clean pattern**: Minimal shadows on second candle

## Visual Pattern

```
Dark Cloud Cover (Top Reversal):

    [=====]             First: Long bullish
     |    |             (uptrend continuation)
          |
          [====]        Second: Opens higher (gap),
           |   |        closes deep into first
           |   |        (bear takeover)

Gap up shows strength, but close shows weakness
Bears overwhelm bulls during the session
```

## Interpretation

The Dark Cloud Cover signals bearish reversal through:

1. **False strength**: Gap up suggests continued bullish momentum
2. **Reversal action**: Strong decline during session shows bear strength
3. **Penetration**: Closing below midpoint negates bullish candle
4. **Distribution**: Often marks smart money selling
5. **Sentiment shift**: Bulls trapped, bears in control
6. **Failed breakout**: New highs rejected completely
7. **Trend exhaustion**: Uptrend losing momentum

### Reliability Factors

| Factor | Low Reliability | Medium Reliability | High Reliability |
|--------|----------------|-------------------|------------------|
| Trend Strength | Weak uptrend | Clear uptrend | Strong/extended uptrend |
| Penetration | 50-60% | 60-75% | 75%+ into body |
| Candle Size | Small bodies | Medium bodies | Long bodies |
| Gap Size | Small gap | Medium gap | Large gap |
| Volume | Low/normal | Increasing | High spike on 2nd |
| Technical Level | Random | Near resistance | At major resistance |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Example: Dark Cloud Cover at Resistance

```ruby
open, high, low, close = load_ohlc_data('AAPL')

pattern = SQA::TAI.cdl_darkcloudcover(open, high, low, close)
sma_20 = SQA::TAI.sma(close, period: 20)
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last == -100
  puts "Dark Cloud Cover detected!"

  # Verify uptrend context
  uptrend = close[-3] > sma_20[-3] &&
            close[-3] > close[-10]

  # Calculate penetration depth
  first_body = close[-2] - open[-2]
  penetration = close[-2] - close[-1]
  penetration_pct = (penetration / first_body * 100).round(2)

  puts "\nPenetration: #{penetration_pct}%"

  if penetration_pct > 75
    puts "DEEP penetration - Very strong signal"
  elsif penetration_pct > 60
    puts "Good penetration - Strong signal"
  else
    puts "Minimum penetration - Fair signal"
  end

  # Check gap
  gap = open[-1] - high[-2]
  gap_pct = (gap / close[-2] * 100).round(2)
  puts "Gap up: #{gap_pct}%"

  # Check resistance
  resistance = close[-30..-3].max
  at_resistance = (high[-1] - resistance).abs < resistance * 0.02

  if uptrend && penetration_pct > 60 && at_resistance
    puts "\n*** TEXTBOOK DARK CLOUD COVER ***"
    puts "At resistance level"
    puts "Deep penetration into bullish candle"
    puts "RSI: #{rsi.last.round(2)}"

    if rsi.last > 70
      puts "OVERBOUGHT + Dark Cloud = VERY STRONG bearish signal"
    end
  end
end
```

## Example: Volume Analysis

```ruby
open, high, low, close, volume = load_ohlc_volume_data('TSLA')

pattern = SQA::TAI.cdl_darkcloudcover(open, high, low, close)

if pattern.last == -100
  puts "Dark Cloud Cover detected"

  # Analyze volume pattern
  vol1 = volume[-2]  # Bullish candle
  vol2 = volume[-1]  # Dark cloud candle
  avg_vol = volume[-20..-3].sum / 18.0

  puts "\nVolume Analysis:"
  puts "Bullish candle: #{vol1.round(0)} (#{(vol1/avg_vol).round(2)}x avg)"
  puts "Dark cloud: #{vol2.round(0)} (#{(vol2/avg_vol).round(2)}x avg)"

  # Ideal: high volume on dark cloud (distribution)
  high_dark_vol = vol2 > avg_vol * 1.5

  if high_dark_vol
    puts "\nEXCELLENT: High volume on dark cloud"
    puts "Shows institutional distribution"
    puts "Pattern very reliable"
  elsif vol2 > vol1
    puts "\nGOOD: Dark cloud volume > Bullish candle"
    puts "Shows selling pressure"
  else
    puts "\nWARNING: Low volume"
    puts "Pattern less reliable - may be false signal"
  end

  # Volume ratio
  vol_ratio = vol2 / vol1
  if vol_ratio > 1.5
    puts "\nDark cloud volume 1.5x+ bullish candle"
    puts "Very strong distribution signal"
  end
end
```

## Example: Penetration Depth Analysis

```ruby
open, high, low, close = load_ohlc_data('NVDA')

pattern = SQA::TAI.cdl_darkcloudcover(open, high, low, close)

if pattern.last == -100
  puts "Dark Cloud Cover - Penetration Analysis"

  # Measure penetration depth precisely
  first_open = open[-2]
  first_close = close[-2]
  first_body = first_close - first_open

  second_close = close[-1]

  # Calculate how far into body
  penetration = first_close - second_close
  penetration_pct = (penetration / first_body * 100).round(2)

  # Distance from midpoint
  midpoint = first_open + (first_body / 2.0)
  distance_from_mid = midpoint - second_close
  distance_pct = (distance_from_mid / first_body * 100).round(2)

  puts "\nPenetration Details:"
  puts "First candle body: $#{first_body.round(2)}"
  puts "Penetration: $#{penetration.round(2)}"
  puts "Penetration %: #{penetration_pct}%"
  puts "Distance below midpoint: #{distance_pct}%"

  # Grade the penetration
  if penetration_pct >= 80
    grade = "EXCEPTIONAL"
    score = 10
  elsif penetration_pct >= 70
    grade = "EXCELLENT"
    score = 9
  elsif penetration_pct >= 60
    grade = "VERY GOOD"
    score = 8
  elsif penetration_pct >= 55
    grade = "GOOD"
    score = 7
  elsif penetration_pct >= 50
    grade = "ACCEPTABLE"
    score = 6
  else
    grade = "INSUFFICIENT"
    score = 4
  end

  puts "\nPenetration Grade: #{grade} (#{score}/10)"

  if penetration_pct >= 70
    puts "\nDeep penetration - High probability reversal"
  elsif penetration_pct >= 60
    puts "\nGood penetration - Solid reversal signal"
  elsif penetration_pct >= 50
    puts "\nMinimum penetration - Monitor for confirmation"
  else
    puts "\nWARNING: Insufficient penetration"
    puts "May not be valid Dark Cloud Cover"
  end
end
```

## Example: Gap Quality Analysis

```ruby
open, high, low, close = load_ohlc_data('MSFT')

pattern = SQA::TAI.cdl_darkcloudcover(open, high, low, close)

if pattern.last == -100
  puts "Dark Cloud Cover - Gap Analysis"

  # Measure gap
  gap = open[-1] - high[-2]
  gap_pct = (gap / close[-2] * 100).round(2)

  puts "\nGap Details:"
  puts "First candle high: $#{high[-2].round(2)}"
  puts "Second candle open: $#{open[-1].round(2)}"
  puts "Gap size: $#{gap.round(2)} (#{gap_pct}%)"

  if gap > 0
    puts "TRUE gap present - Opens above first high"

    if gap_pct > 1.0
      puts "LARGE gap - Very bullish opening"
      puts "Reversal even more significant"
    elsif gap_pct > 0.3
      puts "CLEAR gap - Bullish opening rejected"
    else
      puts "Small gap - Still valid pattern"
    end
  elsif gap > -0.01  # Effectively no gap but opens at/near high
    puts "Opens at first candle high - Valid"
  else
    puts "WARNING: No gap - Weaker pattern"
    puts "Opens below previous high"
  end

  # How far did it reverse from the high?
  reversal = high[-1] - close[-1]
  reversal_pct = (reversal / high[-1] * 100).round(2)

  puts "\nReversal from high: $#{reversal.round(2)} (#{reversal_pct}%)"

  if reversal_pct > 3.0
    puts "STRONG intraday reversal"
  end
end
```

## Trading Strategies

### Entry Rules

#### Conservative Entry (Recommended)
```ruby
# Wait for confirmation after pattern
if pattern[-2] == -100  # Pattern 2 candles ago
  # Confirm with follow-through
  if close[-1] < close[-2] && close.last < close[-1]
    puts "Dark Cloud Cover CONFIRMED"
    entry = close.last
    puts "Enter SHORT at #{entry.round(2)}"
  elsif close.last < [low[-2], low[-1]].min
    puts "Breakdown below pattern - Strong confirmation"
    entry = close.last
    puts "Enter SHORT at #{entry.round(2)}"
  end
end
```

#### Aggressive Entry
```ruby
# Enter on pattern completion
if pattern.last == -100
  entry = close.last

  # Verify penetration is sufficient
  first_body = close[-2] - open[-2]
  penetration = close[-2] - close[-1]
  penetration_pct = (penetration / first_body * 100)

  if penetration_pct >= 60
    puts "Dark Cloud Cover completed - Enter SHORT"
    puts "Entry: #{entry.round(2)}"
    puts "Penetration: #{penetration_pct.round(1)}%"
  else
    puts "WARNING: Weak penetration (#{penetration_pct.round(1)}%)"
    puts "Consider waiting for confirmation"
  end
end
```

#### Pullback Entry
```ruby
# Enter on pullback to resistance
if pattern[-2..-1].include?(-100)
  pattern_high = high[-2..-1].max
  resistance = pattern_high

  # Wait for pullback to resistance that fails
  if high.last >= resistance * 0.98 && close.last < resistance * 0.97
    puts "Pullback to resistance rejected"
    puts "Entry: #{close.last.round(2)}"
    puts "Classic resistance test after Dark Cloud"
  end
end
```

### Stop Loss Placement

```ruby
if pattern.last == -100
  # Stop above pattern high
  pattern_high = [high[-2], high[-1]].max
  stop = pattern_high * 1.01  # 1% buffer

  puts "Stop loss: #{stop.round(2)}"
  puts "Above pattern high (invalidation point)"

  # Alternative: stop above second candle open
  alt_stop = open[-1] * 1.005
  puts "Alternative stop: #{alt_stop.round(2)} (above gap open)"

  # Tighter stop for aggressive traders
  tight_stop = high[-1] * 1.005
  puts "Tight stop: #{tight_stop.round(2)} (above dark cloud high)"

  # Calculate risk
  entry = close.last
  risk = stop - entry
  risk_pct = (risk / entry * 100).round(2)
  puts "Risk: $#{risk.round(2)} (#{risk_pct}%)"
end
```

### Profit Targets

```ruby
if pattern.last == -100
  entry = close.last
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

  # Pattern-based target (height projection)
  first_body = close[-2] - open[-2]
  pattern_target = close[-1] - first_body
  puts "Pattern projection: #{pattern_target.round(2)}"

  # Fibonacci retracement targets
  recent_low = close[-20..-1].min
  range = pattern_high - recent_low
  fib_382 = pattern_high - (range * 0.382)
  fib_500 = pattern_high - (range * 0.500)
  fib_618 = pattern_high - (range * 0.618)

  puts "\nFibonacci Targets:"
  puts "38.2%: #{fib_382.round(2)}"
  puts "50.0%: #{fib_500.round(2)}"
  puts "61.8%: #{fib_618.round(2)}"
end
```

## Example: Complete Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('GOOGL')

pattern = SQA::TAI.cdl_darkcloudcover(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_20 = SQA::TAI.sma(close, period: 20)
sma_50 = SQA::TAI.sma(close, period: 50)

if pattern.last == -100
  puts "Dark Cloud Cover Pattern Analysis"
  puts "=" * 60

  # 1. Trend context
  uptrend = close[-3] > sma_20[-3] && sma_20[-3] > sma_50[-3]
  extended = close[-3] > close[-10]
  context_score = uptrend && extended

  # 2. Penetration depth
  first_body = close[-2] - open[-2]
  penetration = close[-2] - close[-1]
  penetration_pct = (penetration / first_body * 100)
  deep_penetration = penetration_pct >= 65

  # 3. Gap quality
  gap = open[-1] - high[-2]
  gap_pct = (gap / close[-2] * 100)
  has_gap = gap > 0

  # 4. Candle strength
  body1 = close[-2] - open[-2]
  body2 = (open[-1] - close[-1]).abs
  avg_range = (high[-10..-3] - low[-10..-3]).sum / 8.0
  strong_candles = body1 > avg_range * 0.5 && body2 > avg_range * 0.5

  # 5. Volume
  vol1, vol2 = volume[-2], volume[-1]
  avg_vol = volume[-20..-3].sum / 18.0
  high_dark_vol = vol2 > avg_vol * 1.3

  # 6. Resistance level
  resistance = close[-30..-3].max
  at_resistance = (high[-1] - resistance).abs < resistance * 0.03

  # 7. RSI overbought
  overbought = rsi[-2] > 65

  # Calculate quality score
  score = 0
  score += 3 if context_score      # Critical
  score += 3 if deep_penetration   # Critical
  score += 1 if has_gap
  score += 2 if strong_candles     # Very important
  score += 2 if high_dark_vol      # Important
  score += 2 if at_resistance      # Important
  score += 2 if overbought         # Important

  puts "\nQuality Checks:"
  puts "1. Uptrend context: #{context_score} #{context_score ? '✓✓✓' : '✗'}"
  puts "2. Deep penetration (#{penetration_pct.round(1)}%): #{deep_penetration} #{deep_penetration ? '✓✓✓' : '✗'}"
  puts "3. Gap present: #{has_gap} #{has_gap ? '✓' : '✗'}"
  puts "4. Strong candles: #{strong_candles} #{strong_candles ? '✓✓' : '✗'}"
  puts "5. High volume: #{high_dark_vol} #{high_dark_vol ? '✓✓' : '✗'}"
  puts "6. At resistance: #{at_resistance} #{at_resistance ? '✓✓' : '✗'}"
  puts "7. RSI overbought: #{overbought} #{overbought ? '✓✓' : '✗'}"
  puts "\nTotal Score: #{score}/15"

  if score >= 11
    # Calculate trade
    entry = close.last
    pattern_high = [high[-2], high[-1]].max
    stop = pattern_high * 1.01
    risk = stop - entry
    support = close[-40..-1].min
    target = support
    reward = entry - target
    rr = (reward / risk).round(1)

    puts "\n*** EXCELLENT BEARISH SETUP ***"
    puts "-" * 60
    puts "Direction: SHORT"
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

  elsif score >= 8
    puts "\nGOOD SETUP - Consider shorting"
    puts "Decent pattern quality"

  else
    puts "\nWEAK SETUP - Pattern incomplete"
    puts "Missing critical elements"
    puts "Consider waiting for better setup"
  end
end
```

## Pattern Statistics

### Frequency
- **Occurrence**: Common (4-6% of patterns)
- **Best Timeframes**: Daily and 4-hour charts (most reliable)
- **Markets**: All markets, very common in stocks

### Success Rate
- **Perfect pattern**: 75-83% success rate
- **Good pattern**: 65-75% success rate
- **Average pattern**: 55-65% success rate
- **With volume**: 72-80% success rate
- **At resistance**: 78-85% success rate
- **Overbought RSI**: 74-82% success rate

### Average Move
- **Initial decline**: 8-15% from pattern
- **Major declines**: 20-40% move possible
- **Time to target**: 10-25 candles
- **Follow-through**: 68% show continuation

## Best Practices

### Do's
1. Verify established uptrend before pattern
2. Measure penetration depth (>60% minimum)
3. Confirm gap opening (stronger signal)
4. Check volume on dark cloud candle
5. Look for pattern at resistance levels
6. Use RSI to confirm overbought conditions
7. Wait for confirmation on weaker patterns
8. Combine with other bearish indicators
9. Consider candle body lengths
10. Set stops above pattern high

### Don'ts
1. Don't trade without uptrend context
2. Don't accept <50% penetration
3. Don't ignore volume (low volume = weak)
4. Don't use in downtrends (not valid)
5. Don't ignore resistance levels
6. Don't chase after several candles
7. Don't use overly tight stops
8. Don't trade every occurrence
9. Don't ignore confirmation signals
10. Don't forget to check RSI

## Common Mistakes

1. **Insufficient penetration**: Must close >50% into first body
2. **Wrong trend**: Pattern only valid in uptrend
3. **Ignoring volume**: High volume confirms distribution
4. **No gap**: Stronger with gap opening
5. **Small candles**: Both bodies should be substantial
6. **No confirmation**: Weaker patterns need follow-through
7. **Poor stop placement**: Must protect above pattern high

## Related Patterns

### Opposite Pattern
- [Piercing Pattern](cdl_piercing.md) - Bullish equivalent

### Similar Patterns
- [Bearish Engulfing](cdl_engulfing.md) - Complete engulfment
- [Evening Star](cdl_eveningstar.md) - Three-candle version
- [Evening Doji Star](cdl_eveningdojistar.md) - With doji
- [Shooting Star](cdl_shootingstar.md) - Single candle reversal

### Component Patterns
- [Long Line](cdl_longline.md) - First candle characteristics
- [Marubozu](cdl_marubozu.md) - Ideal candle types

## Pattern Variations

### Perfect Dark Cloud Cover
- Strong extended uptrend
- Gap opening >0.5%
- Penetration 70%+ into first body
- Both candles long bodies
- High volume on dark cloud
- At major resistance
- RSI >70
- **Success Rate**: 78-85%

### Good Dark Cloud Cover
- Clear uptrend
- Opens at/near first high
- Penetration 60-70%
- Medium-large bodies
- Above average volume
- **Success Rate**: 68-78%

### Weak Dark Cloud Cover
- Unclear trend
- No gap
- Penetration 50-60%
- Small bodies
- Low volume
- **Success Rate**: 52-62%

## Advanced Concepts

### Pattern Quality Scorer

```ruby
def score_dark_cloud_cover(open, high, low, close, volume)
  return 0 if pattern.last != -100

  score = 0

  # Penetration depth (0-4 points)
  first_body = close[-2] - open[-2]
  penetration = close[-2] - close[-1]
  penetration_pct = (penetration / first_body * 100)

  score += 4 if penetration_pct >= 75
  score += 3 if penetration_pct >= 65
  score += 2 if penetration_pct >= 55
  score += 1 if penetration_pct >= 50

  # Gap quality (0-2 points)
  gap = open[-1] - high[-2]
  gap_pct = (gap / close[-2] * 100)

  score += 2 if gap_pct > 0.5
  score += 1 if gap_pct > 0

  # Candle strength (0-2 points)
  avg_range = (high[-10..-3] - low[-10..-3]).sum / 8.0
  body1 = close[-2] - open[-2]
  body2 = open[-1] - close[-1]

  score += 2 if body1 > avg_range * 0.7 && body2 > avg_range * 0.7
  score += 1 if body1 > avg_range * 0.5 && body2 > avg_range * 0.5

  # Volume (0-2 points)
  avg_vol = volume[-20..-3].sum / 18.0
  score += 2 if volume[-1] > avg_vol * 1.5
  score += 1 if volume[-1] > avg_vol * 1.2

  score  # 0-10
end
```

### Measuring Distribution

```ruby
def analyze_distribution(open, high, low, close, volume)
  if pattern.last == -100
    # Compare volume on up day vs dark cloud
    up_volume = volume[-2]
    down_volume = volume[-1]

    # Distribution: higher volume on down day
    if down_volume > up_volume * 1.3
      puts "DISTRIBUTION DETECTED"
      puts "Down volume significantly exceeds up volume"
      puts "Smart money likely selling"
      return :strong_distribution
    elsif down_volume > up_volume
      puts "Possible distribution"
      return :moderate_distribution
    else
      puts "No distribution signal"
      return :no_distribution
    end
  end
end
```

## Key Takeaways

1. **Bearish reversal** - Signals end of uptrend
2. **Two candles** - Long bullish followed by bearish
3. **Gap opening** - Second candle gaps up (shows initial strength)
4. **Deep penetration** - Must close >50% into first body (>65% ideal)
5. **Volume confirmation** - High volume on dark cloud validates
6. **Resistance** - Most reliable at key resistance levels
7. **Overbought** - RSI >70 strengthens signal
8. **Distribution** - Often marks institutional selling
9. **Failed breakout** - Gap up fails completely
10. **Common pattern** - Appears frequently, reliable when proper

## See Also

- [Piercing Pattern](cdl_piercing.md) - Bullish opposite
- [Bearish Engulfing](cdl_engulfing.md) - Full engulfment version
- [Evening Star](cdl_eveningstar.md) - Three-candle bearish reversal
- [Shooting Star](cdl_shootingstar.md) - Single candle reversal
- [Evening Doji Star](cdl_eveningdojistar.md) - With doji middle
- [Pattern Recognition Overview](index.md)
- [Back to Indicators](../index.md)
