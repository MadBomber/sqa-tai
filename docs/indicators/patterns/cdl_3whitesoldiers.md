# Three White Soldiers Pattern

The Three White Soldiers (also known as Three Advancing White Soldiers) is one of the most powerful bullish reversal patterns in candlestick analysis. It consists of three consecutive long bullish candles with progressively higher closes, appearing after a downtrend and signaling a strong shift to bullish momentum.

## Pattern Type

- **Type**: Bullish Reversal
- **Candles Required**: 3
- **Trend Context**: Appears after downtrend or at market bottom
- **Reliability**: High (one of the most reliable bullish patterns)
- **Frequency**: Moderate (appears 2-3% of the time)

## Usage

```ruby
require 'sqa/tai'

open  = [95.0, 96.0, 97.5, 99.0, 100.5]
high  = [96.5, 98.0, 99.5, 101.0, 102.0]
low   = [94.5, 95.5, 97.0, 98.5, 100.0]
close = [96.0, 97.5, 99.0, 100.5, 101.5]

# Detect Three White Soldiers pattern
pattern = SQA::TAI.cdl_3whitesoldiers(open, high, low, close)

if pattern.last == 100
  puts "Three White Soldiers detected - Strong bullish reversal!"
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
- **0**: No Three White Soldiers pattern detected
- **+100**: Three White Soldiers pattern detected (strong bullish reversal signal)

Note: This pattern only returns bullish signals. See Three Black Crows for the bearish counterpart.

## Pattern Recognition Rules

### Three Candle Structure

1. **First Candle**: Long bullish (white) candle in or after downtrend
2. **Second Candle**: Another long bullish candle that:
   - Opens within first candle's body
   - Closes higher than first candle
   - Has similar or larger body size
3. **Third Candle**: Third consecutive long bullish candle that:
   - Opens within second candle's body
   - Closes higher than second candle
   - Completes the ascending pattern

### Key Characteristics

- All three candles are bullish with long bodies
- Each candle opens within previous candle's body
- Each candle closes progressively higher
- Limited or no lower shadows (closes near highs)
- Ideally similar-sized candles showing consistent buying
- Pattern appears after downtrend or at support
- Resembles soldiers marching upward in formation

### Ideal Pattern Features

- **Consistent bodies**: All three candles roughly same size
- **No gaps**: Candles open within previous bodies (orderly advance)
- **Minimal shadows**: Little to no lower wicks (strong buying)
- **Volume**: Increasing or high volume on all three candles
- **Context**: Follows clear downtrend or consolidation
- **Location**: Forms near support or oversold conditions

## Visual Pattern

```
After downtrend:

            [====]   Third white soldier
             |   |
          [====]     Second white soldier (opens in first, closes higher)
           |   |
        [====]       First white soldier (long bullish)
         |   |

    Stepwise climb with consistent bullish pressure
```

## Interpretation

The Three White Soldiers signals strong bullish reversal through:

1. **Momentum Shift**: Bears lose control on first candle
2. **Acceleration**: Second candle confirms buyers taking over
3. **Confirmation**: Third candle validates new uptrend
4. **Accumulation**: Smart money establishing long positions
5. **Psychological Impact**: Three consecutive up days creates FOMO
6. **Military Formation**: Soldiers advancing in disciplined formation

### Reliability Factors

| Factor | Low Reliability | Medium Reliability | High Reliability |
|--------|----------------|-------------------|------------------|
| Trend Context | Weak downtrend | Clear downtrend | Strong downtrend |
| Candle Size | Short bodies | Medium bodies | Long bodies |
| Shadows | Long lower shadows | Some shadows | Minimal shadows |
| Volume | Decreasing | Normal | Increasing |
| Position | Mid-chart | After decline | At support |
| Consistency | Variable sizes | Similar sizes | Uniform sizes |

## Example: Three White Soldiers After Downtrend

```ruby
open, high, low, close = load_ohlc_data('AAPL')

pattern = SQA::TAI.cdl_3whitesoldiers(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern.last == 100
  # Verify downtrend context
  was_downtrend = close[-4] < sma_50[-4] && sma_50[-4] < sma_200[-4]

  if was_downtrend
    puts "Three White Soldiers after downtrend!"
    puts "HIGH PROBABILITY bullish reversal"
    puts "Previous close: #{close[-4].round(2)}"
    puts "Current close: #{close.last.round(2)}"

    # Calculate advance
    advance = ((close.last - close[-4]) / close[-4] * 100).round(2)
    puts "Three-day advance: #{advance}%"

    # Check candle consistency
    body1 = close[-3] - open[-3]
    body2 = close[-2] - open[-2]
    body3 = close[-1] - open[-1]
    avg_body = (body1 + body2 + body3) / 3

    consistent = (body1 - avg_body).abs < avg_body * 0.3 &&
                 (body2 - avg_body).abs < avg_body * 0.3 &&
                 (body3 - avg_body).abs < avg_body * 0.3

    if consistent
      puts "Candles are consistent - STRONG pattern"
    else
      puts "Candles vary in size - moderate pattern"
    end

    # Check for proper progression
    proper_opens = open[-2] > open[-3] && open[-2] < close[-3] &&
                   open[-1] > open[-2] && open[-1] < close[-2]

    if proper_opens
      puts "Proper opening progression - textbook formation"
    end
  end
end
```

## Example: Three White Soldiers with Volume

```ruby
open, high, low, close, volume = load_ohlc_volume_data('TSLA')

pattern = SQA::TAI.cdl_3whitesoldiers(open, high, low, close)

if pattern.last == 100
  # Volume analysis for each soldier
  vol_soldier1 = volume[-3]
  vol_soldier2 = volume[-2]
  vol_soldier3 = volume[-1]
  avg_volume = volume[-20..-4].sum / 17.0  # Before pattern

  puts "Three White Soldiers Volume Analysis:"
  puts "Soldier 1 volume: #{vol_soldier1.round(0)}"
  puts "Soldier 2 volume: #{vol_soldier2.round(0)}"
  puts "Soldier 3 volume: #{vol_soldier3.round(0)}"
  puts "Average volume (before): #{avg_volume.round(0)}"

  # Check for volume confirmation
  vol_increasing = vol_soldier2 > vol_soldier1 && vol_soldier3 > vol_soldier2
  high_vol = vol_soldier1 > avg_volume &&
             vol_soldier2 > avg_volume &&
             vol_soldier3 > avg_volume

  if vol_increasing && high_vol
    puts "\nEXCELLENT: Increasing volume on all three soldiers"
    puts "High conviction buying - VERY STRONG pattern"
  elsif high_vol
    puts "\nGOOD: High volume on all soldiers"
    puts "Strong buying pressure"
  elsif vol_increasing
    puts "\nDECENT: Volume increasing"
    puts "Building buying momentum"
  else
    puts "\nWEAK: Low or decreasing volume"
    puts "Less reliable - may lack follow-through"
  end

  # Check for exhaustion on third soldier
  if vol_soldier3 > avg_volume * 3
    puts "\nWARNING: Very high volume on third soldier"
    puts "Potential climax buying - watch for pullback"
  end
end
```

## Example: Three White Soldiers at Support

```ruby
open, high, low, close = load_ohlc_data('MSFT')

pattern = SQA::TAI.cdl_3whitesoldiers(open, high, low, close)

# Find support level
support = close[-120..-1].min
prior_low = low[-4]

if pattern.last == 100
  # Check if pattern formed at/near support
  at_support = (prior_low - support).abs < support * 0.02

  if at_support
    puts "Three White Soldiers AT SUPPORT!"
    puts "Support: #{support.round(2)}"
    puts "Pattern started near: #{prior_low.round(2)}"
    puts "Current price: #{close.last.round(2)}"
    puts "\nTextbook reversal from support"
    puts "VERY HIGH PROBABILITY continuation"

    # Calculate potential upside
    resistance = close[-60..-1].max
    potential_move = ((resistance - close.last) / close.last * 100).round(2)
    puts "Potential move to resistance: #{potential_move}%"
  else
    distance = ((prior_low - support) / support * 100).round(2)
    puts "Three White Soldiers #{distance}% from support"
    puts "Moderate setup"
  end
end
```

## Example: Three White Soldiers with RSI

```ruby
open, high, low, close = load_ohlc_data('NVDA')

pattern = SQA::TAI.cdl_3whitesoldiers(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last == 100
  rsi_before = rsi[-4]   # Before pattern
  rsi_current = rsi.last  # After pattern

  puts "Three White Soldiers with RSI:"
  puts "RSI before pattern: #{rsi_before.round(2)}"
  puts "Current RSI: #{rsi_current.round(2)}"
  puts "RSI change: +#{(rsi_current - rsi_before).round(2)}"

  if rsi_before < 30
    puts "\nPattern formed from OVERSOLD"
    puts "Classic reversal from extremes"
    puts "STRONG bullish signal"
  elsif rsi_before < 40
    puts "\nPattern formed from depressed RSI"
    puts "Good reversal setup"
  end

  # Check for overbought
  if rsi_current > 70
    puts "\nWARNING: Now overbought"
    puts "May see pullback - consider taking profits"
  elsif rsi_current > 60
    puts "\nRSI strong but not extreme"
    puts "Momentum confirmed"
  else
    puts "\nRoom to run - RSI not overbought yet"
  end
end
```

## Trading Strategies

### Entry Rules

#### Conservative Entry (Recommended)
```ruby
# Wait for confirmation candle after pattern
if pattern[-2] == 100  # Pattern completed two candles ago
  if close[-1] > close[-2] || close.last > close[-1]
    puts "Three White Soldiers CONFIRMED"
    entry = close.last
    puts "Enter LONG at #{entry.round(2)}"
  else
    puts "Waiting for confirmation - price trying to pull back"
  end
end
```

#### Aggressive Entry
```ruby
# Enter immediately on pattern completion
if pattern.last == 100
  entry = close.last
  puts "Three White Soldiers completed - Enter LONG"
  puts "Entry: #{entry.round(2)}"
  puts "Note: Higher risk without confirmation"
end
```

#### Pullback Entry
```ruby
# Wait for pullback to pattern area
if pattern[-3] == 100  # Pattern 3 candles ago
  pattern_low = [low[-3], low[-2], low[-1]].min

  if close.last < close[-1] && close.last > pattern_low
    puts "Pullback to pattern support"
    puts "Enter LONG at #{close.last.round(2)}"
    puts "Lower risk entry point"
  end
end
```

### Stop Loss Placement

```ruby
if pattern.last == 100
  # Stop below pattern low
  pattern_low = [low[-3], low[-2], low[-1]].min
  stop = pattern_low * 0.99  # 1% buffer

  puts "Stop loss: #{stop.round(2)}"
  puts "Rationale: Below pattern low - invalidates bullish setup"

  # Alternative: Tighter stop below first candle
  tight_stop = low[-3] * 0.995  # 0.5% buffer
  puts "Tighter stop: #{tight_stop.round(2)} (higher risk)"

  # Calculate risk
  entry = close.last
  risk = entry - stop
  risk_percent = (risk / entry * 100).round(2)
  puts "Risk: $#{risk.round(2)} (#{risk_percent}%)"
end
```

### Profit Targets

```ruby
if pattern.last == 100
  entry = close.last
  stop = [low[-3], low[-2], low[-1]].min * 0.99
  risk = entry - stop

  # Risk-based targets
  target_1 = entry + (risk * 2)    # 2:1 R:R
  target_2 = entry + (risk * 3)    # 3:1 R:R
  target_3 = entry + (risk * 5)    # 5:1 R:R

  puts "Risk-Based Targets:"
  puts "T1 (2:1): #{target_1.round(2)}"
  puts "T2 (3:1): #{target_2.round(2)}"
  puts "T3 (5:1): #{target_3.round(2)}"

  # Resistance-based target
  resistance = close[-120..-1].max
  puts "\nResistance target: #{resistance.round(2)}"

  # Moving average target
  sma_50 = SQA::TAI.sma(close, period: 50)
  puts "50 SMA target: #{sma_50.last.round(2)}"
end
```

## Example: Complete Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('GOOGL')

pattern = SQA::TAI.cdl_3whitesoldiers(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern.last == 100
  puts "Three White Soldiers Pattern Analysis"
  puts "=" * 60

  # 1. Trend context
  was_downtrend = close[-4] < sma_50[-4] && sma_50[-4] < sma_200[-4]

  # 2. Support check
  support = close[-120..-1].min
  low_before = low[-4]
  near_support = (low_before - support).abs < support * 0.03

  # 3. RSI analysis
  rsi_before = rsi[-4]
  rsi_oversold = rsi_before < 40

  # 4. Volume analysis
  avg_vol = volume[-20..-4].sum / 17.0
  vol_soldiers = [volume[-3], volume[-2], volume[-1]]
  high_volume = vol_soldiers.all? { |v| v > avg_vol }
  vol_increasing = vol_soldiers[-1] > vol_soldiers[-2] &&
                   vol_soldiers[-2] > vol_soldiers[-1]

  # 5. Candle quality
  body1 = close[-3] - open[-3]
  body2 = close[-2] - open[-2]
  body3 = close[-1] - open[-1]
  bodies = [body1, body2, body3]
  avg_body = bodies.sum / 3.0

  long_bodies = bodies.all? { |b| b > close[-4] * 0.02 }  # At least 2% bodies
  consistent = bodies.all? { |b| (b - avg_body).abs < avg_body * 0.4 }

  # 6. Shadow analysis
  shadow1_low = open[-3] - low[-3]
  shadow2_low = open[-2] - low[-2]
  shadow3_low = open[-1] - low[-1]

  minimal_shadows = [shadow1_low, shadow2_low, shadow3_low].all? do |s|
    s < avg_body * 0.3
  end

  # 7. Progressive advance
  proper_opens = open[-2] < close[-3] && open[-2] > open[-3] &&
                 open[-1] < close[-2] && open[-1] > open[-2]
  progressive_closes = close[-2] > close[-3] && close[-1] > close[-2]

  # Calculate score
  score = 0
  score += 2 if was_downtrend           # Critical
  score += 2 if near_support             # Very important
  score += 1 if rsi_oversold
  score += 1 if high_volume
  score += 1 if long_bodies
  score += 1 if consistent
  score += 1 if minimal_shadows
  score += 1 if proper_opens && progressive_closes

  puts "Quality Checks:"
  puts "1. Downtrend context: #{was_downtrend} #{was_downtrend ? '✓✓' : '✗✗'}"
  puts "2. Near support: #{near_support} #{near_support ? '✓✓' : '✗'}"
  puts "3. RSI oversold (#{rsi_before.round(2)}): #{rsi_oversold} #{rsi_oversold ? '✓' : '✗'}"
  puts "4. High volume: #{high_volume} #{high_volume ? '✓' : '✗'}"
  puts "5. Long bodies: #{long_bodies} #{long_bodies ? '✓' : '✗'}"
  puts "6. Consistent size: #{consistent} #{consistent ? '✓' : '✗'}"
  puts "7. Minimal shadows: #{minimal_shadows} #{minimal_shadows ? '✓' : '✗'}"
  puts "8. Proper formation: #{proper_opens && progressive_closes} #{proper_opens && progressive_closes ? '✓' : '✗'}"
  puts "\nTotal Score: #{score}/10"

  if score >= 7
    # Calculate trade parameters
    entry = close.last
    pattern_low = [low[-3], low[-2], low[-1]].min
    stop = pattern_low * 0.99
    risk = entry - stop

    # Find resistance for target
    resistance = close[-120..-1].max
    target_resistance = resistance
    target_rr3 = entry + (risk * 3)

    target = [target_resistance, target_rr3].min  # Use closer target
    reward = target - entry
    rr_ratio = (reward / risk).round(1)

    puts "\n*** EXCELLENT LONG SETUP ***"
    puts "-" * 60
    puts "Entry: $#{entry.round(2)}"
    puts "Stop: $#{stop.round(2)} (below pattern low)"
    puts "Target: $#{target.round(2)}"
    puts "Risk: $#{risk.round(2)} (#{(risk/entry*100).round(2)}%)"
    puts "Reward: $#{reward.round(2)} (#{(reward/entry*100).round(2)}%)"
    puts "R:R Ratio: 1:#{rr_ratio}"

    # Position sizing (1% account risk)
    account_size = 100000
    risk_amount = account_size * 0.01
    shares = (risk_amount / risk).floor
    position_value = shares * entry

    puts "\nPosition Sizing (1% risk):"
    puts "Shares: #{shares}"
    puts "Position value: $#{position_value.round(2)}"
    puts "Total risk: $#{risk_amount.round(2)}"
    puts "Potential profit: $#{(shares * reward).round(2)}"

  elsif score >= 5
    puts "\nDECENT SETUP - Consider smaller position"
    puts "Missing some ideal conditions"

  else
    puts "\nWEAK SETUP - SKIP"
    puts "Too many missing conditions"
    puts "Wait for better opportunity"
  end
end
```

## Pattern Statistics

### Frequency
- **Occurrence**: Moderate (2-3% of the time)
- **Best Timeframes**: Daily and Weekly (most reliable)
- **Markets**: Works on all markets (stocks, forex, crypto, commodities)

### Success Rate
- **Perfect pattern**: 78-85% success rate
- **Good pattern**: 65-75% success rate
- **Average pattern**: 55-65% success rate
- **At support**: 80-88% success rate
- **With volume**: 72-82% success rate
- **After strong downtrend**: 75-85% success rate

### Average Move
- **Initial advance**: 8-18% from pattern low
- **Major reversals**: 25-45% advance
- **Time to target**: 5-20 candles (varies by timeframe)
- **Follow-through**: 70% show continued strength

## Best Practices

### Do's
1. Wait for established downtrend before taking signal
2. Verify all three candles have substantial bodies
3. Check for minimal lower shadows (strong buying)
4. Look for increasing or consistently high volume
5. Trade near support for best results
6. Confirm with RSI oversold conditions
7. Use proper stop loss below pattern low
8. Scale out at multiple targets
9. Look for consistent candle sizes
10. Verify proper candle progression (opens within bodies)

### Don'ts
1. Don't trade in existing uptrend (not a reversal there)
2. Don't ignore volume (critical confirmation)
3. Don't trade with long lower shadows (shows selling pressure)
4. Don't enter without stop loss
5. Don't ignore overall market conditions
6. Don't trade if candles are tiny (weak pattern)
7. Don't chase if you missed entry
8. Don't confuse with ordinary advance
9. Don't trade if RSI already overbought
10. Don't risk more than 1-2% account

## Common Mistakes

1. **Trading in uptrend**: Pattern needs downtrend for reversal validity
2. **Ignoring candle quality**: Bodies must be long and consistent
3. **Poor stop placement**: Must protect below pattern low
4. **No volume confirmation**: High volume = high conviction
5. **Entering too late**: Best entry is at/near pattern completion
6. **Ignoring shadows**: Long lower shadows = selling pressure
7. **Wrong timeframe**: More reliable on daily/weekly charts

## Related Patterns

### Similar Bullish Patterns
- [Three Line Strike](cdl_3linestrike.md) - Includes fourth candle
- [Morning Star](cdl_morningstar.md) - Three-candle bullish reversal
- [Three Inside Up](cdl_3inside.md) - Related three-candle pattern
- [Advance Block](cdl_advanceblock.md) - Similar but bearish warning

### Opposite Pattern
- [Three Black Crows](cdl_3blackcrows.md) - Bearish equivalent

### Component Patterns
- [Long Line](cdl_longline.md) - Characteristics of each soldier
- [Marubozu](cdl_marubozu.md) - Soldiers often resemble this

## Pattern Variations

### Perfect Three White Soldiers
- All three candles long and similar size
- Opens within previous bodies (no gaps)
- Closes at or near highs (minimal shadows)
- High volume on all three
- Appears at support after strong downtrend
- **Success Rate**: 80-85%

### Good Three White Soldiers
- Long bodies with some variation
- Mostly minimal shadows
- Good volume
- Clear downtrend context
- **Success Rate**: 65-75%

### Weak Three White Soldiers
- Variable candle sizes
- Long lower shadows (buying hesitation)
- Low volume
- No clear downtrend
- Not at support
- **Success Rate**: 45-55%

### Modified Patterns
- **Identical Three Soldiers**: All three nearly same size (stronger)
- **Deliberate Three Soldiers**: Small gaps between soldiers (weaker)

## Advanced Concepts

### Soldier Quality Score
```ruby
def score_three_white_soldiers(open, high, low, close, volume)
  return 0 unless pattern.last == 100

  score = 0

  # Body length (0-2 points)
  bodies = [-3, -2, -1].map { |i| close[i] - open[i] }
  avg_body = bodies.sum / 3.0
  score += 2 if avg_body > close.last * 0.025  # 2.5%+ bodies
  score += 1 if avg_body > close.last * 0.015  # 1.5%+ bodies

  # Consistency (0-2 points)
  std_dev = Math.sqrt(bodies.sum { |b| (b - avg_body)**2 } / 3)
  score += 2 if std_dev < avg_body * 0.2   # Very consistent
  score += 1 if std_dev < avg_body * 0.4   # Fairly consistent

  # Shadow analysis (0-2 points)
  shadows = [-3, -2, -1].map { |i| open[i] - low[i] }
  score += 2 if shadows.all? { |s| s < avg_body * 0.2 }
  score += 1 if shadows.all? { |s| s < avg_body * 0.4 }

  # Volume (0-2 points)
  avg_vol = volume[-20..-4].sum / 17.0
  soldier_vols = volume[-3..-1]
  score += 2 if soldier_vols.all? { |v| v > avg_vol * 1.3 }
  score += 1 if soldier_vols.all? { |v| v > avg_vol }

  # Formation (0-2 points)
  proper_form = open[-2] < close[-3] && open[-2] > open[-3] &&
                open[-1] < close[-2] && open[-1] > open[-2] &&
                close[-2] > close[-3] && close[-1] > close[-2]
  score += 2 if proper_form

  score  # 0-10
end
```

## Key Takeaways

1. **Highly reliable** when all conditions present (downtrend, support, volume)
2. **Three is key** - shows persistence, not just one-off buying
3. **Context critical** - must follow downtrend for reversal signal
4. **Quality matters** - long consistent bodies with minimal shadows
5. **Volume confirms** - high volume shows conviction
6. **Stop protection** - always use stop below pattern low
7. **Patient entry** - best results with confirmation
8. **Multiple targets** - scale out as pattern plays out
9. **Risk management** - never risk more than 1-2% per trade
10. **Best at support** - successful bounce = strongest signal

## See Also

- [Three Black Crows](cdl_3blackcrows.md) - Bearish counterpart
- [Three Line Strike](cdl_3linestrike.md) - Four-candle version
- [Morning Star](cdl_morningstar.md) - Three-candle reversal
- [Three Inside Up](cdl_3inside.md) - Related pattern
- [Pattern Recognition Overview](../index.md)
- [Back to Indicators](../index.md)
