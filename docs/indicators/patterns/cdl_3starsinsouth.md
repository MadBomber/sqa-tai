# Three Stars in the South Pattern

The Three Stars in the South is a rare but highly reliable three-candle bullish reversal pattern that appears during downtrends. It consists of three consecutive black (bearish) candles with progressively smaller bodies and lower shadows, indicating that selling pressure is diminishing and a bullish reversal is imminent.

## Pattern Type

- **Type**: Bullish Reversal
- **Candles Required**: 3
- **Trend Context**: Appears during or at the end of a downtrend
- **Reliability**: Very High (rare but accurate when it appears)
- **Frequency**: Rare (appears less than 1% of the time)

## Usage

```ruby
require 'sqa/tai'

open  = [100.0, 98.0, 97.0, 96.5, 97.0]
high  = [100.5, 98.5, 97.3, 96.8, 98.0]
low   = [96.0, 96.0, 96.5, 96.3, 96.8]
close = [98.0, 97.0, 96.8, 96.7, 97.5]

# Detect Three Stars in the South pattern
pattern = SQA::TAI.cdl_3starsinsouth(open, high, low, close)

if pattern.last == 100
  puts "Three Stars in the South detected - Rare bullish reversal!"
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
- **0**: No Three Stars in the South pattern detected
- **+100**: Three Stars in the South pattern detected (bullish reversal signal)

Note: This pattern only returns bullish signals as it's specifically a bullish reversal pattern.

## Pattern Recognition Rules

### Three Candle Structure

1. **First Candle**: Long black candle with a long lower shadow
   - Significant bearish body
   - Long lower shadow (at least as long as body)
   - Shows strong selling but some buying support

2. **Second Candle**: Smaller black candle
   - Opens within first candle's body
   - Smaller body than first candle
   - Shorter lower shadow than first
   - Does not make new low (higher low)

3. **Third Candle**: Small black marubozu or near-marubozu
   - Very small body
   - Opens within second candle's body
   - Little to no shadow
   - Does not make new low (higher low again)

### Key Characteristics

- All three candles are black (bearish)
- Progressive decrease in body size
- Progressive decrease in lower shadow length
- Each candle makes a higher low
- Pattern shows exhaustion of selling pressure
- Final candle is almost a doji-like small body
- Pattern resembles three stars aligned in the southern sky
- Indicates sellers losing momentum

### Ideal Pattern Features

- **Clear downtrend**: Pattern must occur during established downtrend
- **First candle**: Long body with significant lower shadow
- **Progressive shortening**: Each candle noticeably smaller
- **Higher lows**: Each low is higher than previous
- **Third candle**: Very small body, minimal shadows
- **Volume**: Often declining volume through pattern
- **Context**: Forms near support or oversold levels

## Visual Pattern

```
During downtrend:

First: [====]         Long black with long lower shadow
         |   |
         |   |
        /     \

Second: [==]          Smaller black, shorter shadow, higher low
         |  |
         | /

Third:  [=]           Tiny black, no/minimal shadow, higher low still
        | |

Three diminishing "stars" showing selling exhaustion
```

## Interpretation

The Three Stars in the South signals bullish reversal through:

1. **Selling Exhaustion**: Three consecutive down days but weakening
2. **Higher Lows**: Each candle refuses to make new low
3. **Shrinking Bodies**: Sellers unable to push price down as much
4. **Diminishing Shadows**: Less intraday volatility
5. **Capitulation**: Final small candle shows sellers exhausted
6. **Support**: Pattern shows strong support emerging

### Reliability Factors

| Factor | Low Reliability | Medium Reliability | High Reliability |
|--------|----------------|-------------------|------------------|
| Trend Context | Weak downtrend | Clear downtrend | Strong downtrend |
| Body Progression | Irregular | Some decrease | Clear decrease |
| Lower Shadows | Inconsistent | Mostly decreasing | Clearly decreasing |
| Third Candle | Medium body | Small body | Tiny/doji-like |
| Higher Lows | Slight | Clear | Very distinct |
| Support | No support | Some support | At key support |

## Example: Three Stars in the South After Downtrend

```ruby
open, high, low, close = load_ohlc_data('AAPL')

pattern = SQA::TAI.cdl_3starsinsouth(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)

if pattern.last == 100
  puts "RARE: Three Stars in the South detected!"

  # Verify downtrend context
  downtrend = close[-4] < sma_50[-4] && close[-5] < close[-10]

  if downtrend
    puts "Pattern formed after downtrend - HIGH RELIABILITY"

    # Check progressive characteristics
    body1 = (close[-3] - open[-3]).abs
    body2 = (close[-2] - open[-2]).abs
    body3 = (close[-1] - open[-1]).abs

    shadow1 = open[-3] - low[-3]
    shadow2 = open[-2] - low[-2]
    shadow3 = open[-1] - low[-1]

    puts "\nCandle Analysis:"
    puts "Candle 1 - Body: #{body1.round(2)}, Shadow: #{shadow1.round(2)}"
    puts "Candle 2 - Body: #{body2.round(2)}, Shadow: #{shadow2.round(2)}"
    puts "Candle 3 - Body: #{body3.round(2)}, Shadow: #{shadow3.round(2)}"

    # Check for proper progression
    bodies_decreasing = body1 > body2 && body2 > body3
    shadows_decreasing = shadow1 > shadow2 && shadow2 >= shadow3

    higher_lows = low[-2] > low[-3] && low[-1] > low[-2]

    if bodies_decreasing && shadows_decreasing && higher_lows
      puts "\nPERFECT PATTERN - All conditions met!"
      puts "Selling pressure clearly exhausting"
    end

    # Calculate potential reversal
    pattern_low = [low[-3], low[-2], low[-1]].min
    puts "\nPattern low: #{pattern_low.round(2)}"
    puts "Current: #{close.last.round(2)}"
    puts "Excellent risk/reward from this rare pattern"
  end
end
```

## Example: Three Stars with RSI Oversold

```ruby
open, high, low, close = load_ohlc_data('TSLA')

pattern = SQA::TAI.cdl_3starsinsouth(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last == 100
  rsi_start = rsi[-4]
  rsi_current = rsi.last

  puts "Three Stars in the South with RSI:"
  puts "RSI before pattern: #{rsi_start.round(2)}"
  puts "Current RSI: #{rsi_current.round(2)}"

  if rsi_start < 30
    puts "\nPattern formed in OVERSOLD territory!"
    puts "Extremely high probability reversal"
    puts "Classic exhaustion bottom"
  elsif rsi_start < 40
    puts "\nPattern formed with depressed RSI"
    puts "Strong reversal signal"
  end

  # Check RSI behavior during pattern
  rsi1 = rsi[-3]
  rsi2 = rsi[-2]
  rsi3 = rsi[-1]

  rsi_divergence = rsi3 > rsi2 && rsi2 > rsi1 && close[-1] <= close[-3]

  if rsi_divergence
    puts "\nBULLISH DIVERGENCE present!"
    puts "RSI making higher lows while price stalling"
    puts "VERY STRONG confirmation"
  end
end
```

## Example: Three Stars at Support

```ruby
open, high, low, close = load_ohlc_data('MSFT')

pattern = SQA::TAI.cdl_3starsinsouth(open, high, low, close)

# Find support level
support = close[-120..-5].min
pattern_low = [low[-3], low[-2], low[-1]].min

if pattern.last == 100
  # Check if at support
  at_support = (pattern_low - support).abs < support * 0.02

  if at_support
    puts "Three Stars in the South AT SUPPORT!"
    puts "Support: #{support.round(2)}"
    puts "Pattern low: #{pattern_low.round(2)}"
    puts "\nTEXTBOOK reversal setup"
    puts "Support holding + selling exhaustion"
    puts "VERY HIGH PROBABILITY bullish reversal"

    # Calculate risk/reward
    resistance = close[-60..-1].max
    entry = close.last
    stop = pattern_low * 0.99
    target = resistance

    risk = entry - stop
    reward = target - entry
    rr = (reward / risk).round(2)

    puts "\nRisk/Reward:"
    puts "Entry: #{entry.round(2)}"
    puts "Stop: #{stop.round(2)}"
    puts "Target: #{target.round(2)}"
    puts "R:R Ratio: 1:#{rr}"
  end
end
```

## Example: Volume Analysis

```ruby
open, high, low, close, volume = load_ohlc_volume_data('NVDA')

pattern = SQA::TAI.cdl_3starsinsouth(open, high, low, close)

if pattern.last == 100
  # Analyze volume through pattern
  vol1 = volume[-3]
  vol2 = volume[-2]
  vol3 = volume[-1]
  avg_vol = volume[-20..-4].sum / 17.0

  puts "Three Stars in the South Volume Analysis:"
  puts "Star 1 volume: #{vol1.round(0)}"
  puts "Star 2 volume: #{vol2.round(0)}"
  puts "Star 3 volume: #{vol3.round(0)}"
  puts "Avg volume: #{avg_vol.round(0)}"

  # Ideal: decreasing volume shows selling exhaustion
  vol_decreasing = vol1 > vol2 && vol2 > vol3
  vol_below_avg = vol3 < avg_vol

  if vol_decreasing && vol_below_avg
    puts "\nIDEAL: Declining volume through pattern"
    puts "Selling pressure truly exhausted"
    puts "VERY STRONG signal"
  elsif vol_decreasing
    puts "\nGOOD: Volume declining"
    puts "Seller fatigue evident"
  elsif vol_below_avg
    puts "\nDECENT: Volume subdued on final candle"
    puts "Sellers losing interest"
  else
    puts "\nWARNING: High volume maintained"
    puts "May need more time to bottom"
  end
end
```

## Trading Strategies

### Entry Rules

#### Conservative Entry (Recommended)
```ruby
# Wait for bullish confirmation candle
if pattern[-2] == 100  # Pattern completed 2 candles ago
  if close[-1] > open[-1] && close.last > close[-1]
    puts "Three Stars CONFIRMED with bullish follow-through"
    entry = close.last
    puts "Enter LONG at #{entry.round(2)}"
  end
end
```

#### Aggressive Entry
```ruby
# Enter at pattern completion
if pattern.last == 100
  entry = close.last
  pattern_low = [low[-3], low[-2], low[-1]].min
  stop = pattern_low * 0.99

  puts "Entering LONG at pattern completion"
  puts "Entry: #{entry.round(2)}"
  puts "Stop: #{stop.round(2)}"
  puts "Note: Rare pattern - high confidence despite no confirmation"
end
```

#### Pullback Entry
```ruby
# Wait for minor pullback after pattern
if pattern[-3..-1].include?(100)
  pattern_idx = -3 + pattern[-3..-1].index(100)
  pattern_high = high[pattern_idx..-1].max

  # Enter on pullback that holds pattern low
  pattern_low = [low[-3], low[-2], low[-1]].min

  if close.last < pattern_high && low.last > pattern_low
    puts "Pullback entry opportunity"
    puts "Entry: #{close.last.round(2)}"
    puts "Protected above pattern low"
  end
end
```

### Stop Loss Placement

```ruby
if pattern.last == 100
  # Stop below pattern low (standard)
  pattern_low = [low[-3], low[-2], low[-1]].min
  stop = pattern_low * 0.985  # 1.5% buffer

  puts "Stop loss: #{stop.round(2)}"
  puts "Rationale: Below all three stars"

  # Calculate risk
  entry = close.last
  risk = entry - stop
  risk_pct = (risk / entry * 100).round(2)

  puts "Risk: $#{risk.round(2)} (#{risk_pct}%)"

  # Alternative: Tighter stop below third candle only
  tight_stop = low[-1] * 0.99
  puts "\nTighter stop: #{tight_stop.round(2)}"
  puts "(Higher risk but final star is key support)"
end
```

### Profit Targets

```ruby
if pattern.last == 100
  entry = close.last
  pattern_low = [low[-3], low[-2], low[-1]].min
  stop = pattern_low * 0.985
  risk = entry - stop

  # Risk-based targets
  target_1 = entry + (risk * 2)    # 2R
  target_2 = entry + (risk * 3)    # 3R
  target_3 = entry + (risk * 5)    # 5R (rare pattern justifies)

  puts "Risk-Based Targets:"
  puts "T1 (2R): #{target_1.round(2)}"
  puts "T2 (3R): #{target_2.round(2)}"
  puts "T3 (5R): #{target_3.round(2)}"

  # Technical targets
  sma_50 = SQA::TAI.sma(close, period: 50)
  resistance = close[-60..-1].max

  puts "\nTechnical Targets:"
  puts "50 SMA: #{sma_50.last.round(2)}"
  puts "Recent high: #{resistance.round(2)}"
end
```

## Example: Complete Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('GOOGL')

pattern = SQA::TAI.cdl_3starsinsouth(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern.last == 100
  puts "Three Stars in the South Pattern Analysis"
  puts "=" * 60
  puts "(RARE PATTERN - High significance)"

  # 1. Trend context
  downtrend = close[-4] < sma_50[-4] && sma_50[-4] < sma_200[-4]

  # 2. Pattern structure
  body1 = (close[-3] - open[-3]).abs
  body2 = (close[-2] - open[-2]).abs
  body3 = (close[-1] - open[-1]).abs

  shadow1 = open[-3] - low[-3]
  shadow2 = open[-2] - low[-2]
  shadow3 = open[-1] - low[-1]

  bodies_decrease = body1 > body2 && body2 > body3 &&
                    body3 < body2 * 0.6  # Third significantly smaller

  shadows_decrease = shadow1 > shadow2 && shadow2 >= shadow3

  first_long_shadow = shadow1 >= body1

  higher_lows = low[-2] > low[-3] && low[-1] > low[-2]

  third_small = body3 < body1 * 0.3  # Less than 30% of first

  # 3. Support check
  support = close[-120..-5].min
  pattern_low = [low[-3], low[-2], low[-1]].min
  at_support = (pattern_low - support).abs < support * 0.03

  # 4. RSI oversold
  rsi_before = rsi[-4]
  oversold = rsi_before < 40

  # 5. Volume declining
  vol1, vol2, vol3 = volume[-3], volume[-2], volume[-1]
  avg_vol = volume[-20..-4].sum / 17.0
  vol_declining = vol1 > vol2 && vol2 > vol3

  # 6. All three candles are black
  all_black = close[-3] < open[-3] &&
              close[-2] < open[-2] &&
              close[-1] < open[-1]

  # Calculate quality score
  score = 0
  score += 3 if downtrend              # Critical
  score += 2 if bodies_decrease        # Very important
  score += 2 if higher_lows             # Very important
  score += 2 if first_long_shadow      # Important
  score += 1 if shadows_decrease
  score += 1 if third_small
  score += 2 if at_support             # Very important
  score += 1 if oversold
  score += 1 if vol_declining
  score += 1 if all_black

  puts "\nQuality Checks:"
  puts "1. Downtrend: #{downtrend} #{downtrend ? '✓✓✓' : '✗'}"
  puts "2. Bodies decreasing: #{bodies_decrease} #{bodies_decrease ? '✓✓' : '✗'}"
  puts "3. Higher lows: #{higher_lows} #{higher_lows ? '✓✓' : '✗'}"
  puts "4. First long shadow: #{first_long_shadow} #{first_long_shadow ? '✓✓' : '✗'}"
  puts "5. Shadows decreasing: #{shadows_decrease} #{shadows_decrease ? '✓' : '✗'}"
  puts "6. Third tiny: #{third_small} #{third_small ? '✓' : '✗'}"
  puts "7. At support: #{at_support} #{at_support ? '✓✓' : '✗'}"
  puts "8. RSI oversold (#{rsi_before.round(2)}): #{oversold} #{oversold ? '✓' : '✗'}"
  puts "9. Volume declining: #{vol_declining} #{vol_declining ? '✓' : '✗'}"
  puts "10. All black candles: #{all_black} #{all_black ? '✓' : '✗'}"
  puts "\nTotal Score: #{score}/16"

  if score >= 11
    # Calculate trade
    entry = close.last
    stop = pattern_low * 0.985
    risk = entry - stop

    resistance = close[-60..-1].max
    target = resistance
    reward = target - entry
    rr = (reward / risk).round(1)

    puts "\n*** EXCELLENT SETUP (Rare Pattern!) ***"
    puts "-" * 60
    puts "Entry: $#{entry.round(2)}"
    puts "Stop: $#{stop.round(2)}"
    puts "Target: $#{target.round(2)}"
    puts "Risk: $#{risk.round(2)} (#{(risk/entry*100).round(2)}%)"
    puts "Reward: $#{reward.round(2)} (#{(reward/entry*100).round(2)}%)"
    puts "R:R: 1:#{rr}"

    # Position sizing
    account = 100000
    risk_amount = account * 0.02  # 2% for rare high-quality pattern
    shares = (risk_amount / risk).floor

    puts "\nPosition Sizing (2% risk for rare pattern):"
    puts "Shares: #{shares}"
    puts "Position: $#{(shares * entry).round(2)}"
    puts "Risk: $#{risk_amount.round(2)}"
    puts "Potential profit: $#{(shares * reward).round(2)}"

  elsif score >= 8
    puts "\nGOOD SETUP - Consider trade"
    puts "Rare pattern still valuable"

  else
    puts "\nWEAK SETUP - Pattern incomplete or poor context"
    puts "Wait for better setup"
  end
end
```

## Pattern Statistics

### Frequency
- **Occurrence**: Very Rare (less than 1% of the time)
- **Best Timeframes**: Daily and Weekly charts
- **Markets**: Most reliable in stock and commodity markets

### Success Rate
- **Perfect pattern**: 85-92% success rate
- **Good pattern**: 75-85% success rate
- **Average pattern**: 65-75% success rate
- **At support**: 88-95% success rate
- **With volume decline**: 80-88% success rate
- **Oversold RSI**: 82-90% success rate

### Average Move
- **Initial reversal**: 10-25% from pattern low
- **Major reversals**: 30-60% advance
- **Time to target**: 10-30 candles
- **Follow-through**: 85% show strong continuation

## Best Practices

### Do's
1. Recognize the rarity and significance of this pattern
2. Verify clear downtrend before pattern
3. Confirm bodies progressively decrease
4. Check that each candle makes higher low
5. Verify first candle has long lower shadow
6. Ensure third candle is very small
7. Trade when at support for best results
8. Use RSI to confirm oversold conditions
9. Look for declining volume through pattern
10. Be patient - pattern is rare but reliable

### Don'ts
1. Don't ignore the pattern due to rarity
2. Don't trade without downtrend context
3. Don't accept if bodies don't decrease
4. Don't ignore if lows are not progressively higher
5. Don't trade if first shadow isn't long
6. Don't enter if third candle is large
7. Don't skip confirmation in uncertain conditions
8. Don't use tight stops - pattern needs room
9. Don't ignore volume signals
10. Don't overtrade - this pattern is genuinely rare

## Common Mistakes

1. **Misidentifying pattern**: Must have exact structure
2. **Wrong trend context**: Needs clear downtrend
3. **Ignoring progression**: Bodies and shadows must decrease
4. **Missing higher lows**: Critical feature
5. **Poor stop placement**: Must protect below pattern
6. **Ignoring rarity**: Pattern's rarity adds significance
7. **No confirmation**: Even rare patterns benefit from confirmation

## Related Patterns

### Similar Bullish Patterns
- [Morning Star](cdl_morningstar.md) - Three-candle bullish reversal
- [Three White Soldiers](cdl_3whitesoldiers.md) - Bullish three-candle pattern
- [Abandoned Baby](cdl_abandonedbaby.md) - Another rare reversal

### Component Patterns
- [Long Line](cdl_longline.md) - First candle characteristics
- [Short Line](cdl_shortline.md) - Third candle characteristics
- [Hammer](cdl_hammer.md) - First candle similar structure

## Pattern Variations

### Perfect Three Stars in the South
- Clear downtrend context
- First candle: long body, long lower shadow
- Second candle: noticeably smaller, shorter shadow, higher low
- Third candle: tiny body, minimal shadow, higher low
- All black candles
- Declining volume
- At support level
- **Success Rate**: 88-95%

### Good Three Stars in the South
- Downtrend present
- Progressive decrease in sizes
- Higher lows maintained
- Some variation acceptable
- **Success Rate**: 75-85%

### Weak Three Stars in the South
- Unclear downtrend
- Inconsistent sizing
- Higher lows not clear
- High volume maintained
- **Success Rate**: 55-65%

## Advanced Concepts

### Pattern Quality Scorer

```ruby
def score_three_stars_south(open, high, low, close, volume)
  return 0 unless pattern.last == 100

  score = 0

  # Body progression (0-3 points)
  body1 = (close[-3] - open[-3]).abs
  body2 = (close[-2] - open[-2]).abs
  body3 = (close[-1] - open[-1]).abs

  score += 3 if body1 > body2 && body2 > body3 && body3 < body1 * 0.3
  score += 2 if body1 > body2 && body2 > body3 && body3 < body1 * 0.5
  score += 1 if body1 > body2 && body2 > body3

  # Shadow progression (0-2 points)
  shadow1 = open[-3] - low[-3]
  shadow2 = open[-2] - low[-2]
  shadow3 = open[-1] - low[-1]

  score += 2 if shadow1 > shadow2 && shadow2 >= shadow3 && shadow1 >= body1
  score += 1 if shadow1 > shadow2 && shadow2 >= shadow3

  # Higher lows (0-3 points)
  if low[-2] > low[-3] && low[-1] > low[-2]
    diff1 = low[-2] - low[-3]
    diff2 = low[-1] - low[-2]

    score += 3 if diff1 > body1 * 0.1 && diff2 > body2 * 0.1
    score += 2 if diff1 > 0 && diff2 > 0
  end

  # Volume decline (0-2 points)
  vol1, vol2, vol3 = volume[-3], volume[-2], volume[-1]
  score += 2 if vol1 > vol2 && vol2 > vol3
  score += 1 if vol3 < vol1

  # All black candles (0-2 points)
  all_black = close[-3] < open[-3] &&
              close[-2] < open[-2] &&
              close[-1] < open[-1]
  score += 2 if all_black

  score  # 0-12
end
```

## Key Takeaways

1. **Extremely rare** but highly reliable pattern
2. **Selling exhaustion** clearly visible through progression
3. **Higher lows** critical feature distinguishing from mere decline
4. **Progressive shrinking** shows diminishing bearish pressure
5. **Downtrend required** for reversal signal validity
6. **Support confluence** dramatically increases success rate
7. **Volume decline** confirms seller exhaustion
8. **Long first shadow** shows initial buying interest
9. **Tiny third candle** signals capitulation complete
10. **Don't miss it** - rarity makes it significant when it appears

## See Also

- [Morning Star](cdl_morningstar.md) - Common bullish reversal
- [Three White Soldiers](cdl_3whitesoldiers.md) - Bullish three-pattern
- [Hammer](cdl_hammer.md) - Single candle reversal
- [Abandoned Baby](cdl_abandonedbaby.md) - Another rare reversal
- [Pattern Recognition Overview](index.md)
- [Back to Indicators](../index.md)
