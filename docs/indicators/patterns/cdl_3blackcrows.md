# Three Black Crows Pattern

The Three Black Crows is one of the most reliable and powerful bearish reversal patterns in candlestick analysis. It consists of three consecutive long bearish candles, each opening within the previous candle's body and closing progressively lower, signaling a strong shift from bullish to bearish momentum.

## Pattern Type

- **Type**: Bearish Reversal
- **Candles Required**: 3
- **Trend Context**: Appears after uptrend or at market top
- **Reliability**: High (one of the most reliable bearish patterns)
- **Frequency**: Moderate (appears 2-3% of the time)

## Usage

```ruby
require 'sqa/tai'

open  = [105.0, 104.5, 103.0, 101.5, 100.0]
high  = [106.0, 105.0, 103.5, 102.0, 100.5]
low   = [104.0, 103.0, 101.0, 99.5, 98.0]
close = [104.5, 103.0, 101.5, 100.0, 98.5]

# Detect Three Black Crows pattern
pattern = SQA::TAI.cdl_3blackcrows(open, high, low, close)

if pattern.last == -100
  puts "Three Black Crows detected - Strong bearish reversal!"
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
- **0**: No Three Black Crows pattern detected
- **-100**: Three Black Crows pattern detected (strong bearish reversal signal)

Note: This pattern only returns bearish signals (-100). There is no bullish variant from this indicator (see Three White Soldiers for the bullish counterpart).

## Pattern Recognition Rules

### Three Candle Structure

1. **First Candle**: Long bearish (black/red) candle that closes near its low
2. **Second Candle**: Opens within first candle's body, closes lower, creating another long bearish candle
3. **Third Candle**: Opens within second candle's body, closes even lower, completing the pattern

### Key Characteristics

- All three candles are bearish with long bodies
- Each candle opens within the previous candle's real body (not at gaps)
- Each candle closes progressively lower
- Limited or no upper shadows (closes near the lows)
- Ideally similar-sized candles showing consistent selling pressure
- Pattern appears after an uptrend or at market tops

### Ideal Pattern Features

- **Consistent bodies**: All three candles roughly the same size
- **No gaps**: Candles open within previous bodies (orderly decline)
- **Minimal shadows**: Little to no upper wicks (strong selling)
- **Volume**: Increasing or high volume on all three candles
- **Context**: Follows a clear uptrend

## Visual Pattern

```
After uptrend:

    [====]       First black crow
     |   |

      [====]     Second black crow (opens in first, closes lower)
       |   |

        [====]   Third black crow (opens in second, closes lower)
         |   |

    Stepwise decline with consistent bearish pressure
```

## Interpretation

The Three Black Crows signals a significant shift in market sentiment:

1. **Momentum Reversal**: Bulls lose control after each attempt to recover
2. **Distribution**: Smart money exiting positions
3. **Cascading Sell-off**: Three consecutive down days shows persistent selling
4. **Trend Change**: High probability the uptrend has ended
5. **Psychological Impact**: Pattern creates fear and selling pressure

### Reliability Factors

| Factor | Low Reliability | Medium Reliability | High Reliability |
|--------|----------------|-------------------|------------------|
| Trend Context | Weak uptrend | Clear uptrend | Strong uptrend |
| Candle Size | Short bodies | Medium bodies | Long bodies |
| Shadows | Long upper shadows | Some shadows | Minimal shadows |
| Volume | Decreasing | Normal | Increasing |
| Position | Mid-chart | After rally | At resistance |
| Consistency | Variable sizes | Similar sizes | Uniform sizes |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Example: Three Black Crows in Context

```ruby
open, high, low, close = load_ohlc_data('AAPL')

pattern = SQA::TAI.cdl_3blackcrows(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern.last == -100
  # Verify uptrend context
  was_uptrend = close[-4] > sma_50[-4] && sma_50[-4] > sma_200[-4]

  if was_uptrend
    puts "Three Black Crows after strong uptrend!"
    puts "HIGH PROBABILITY reversal"
    puts "Previous close: #{close[-4].round(2)}"
    puts "Current close: #{close.last.round(2)}"

    # Calculate decline
    decline = ((close[-4] - close.last) / close[-4] * 100).round(2)
    puts "Decline: #{decline}%"

    # Check candle consistency
    body1 = (open[-3] - close[-3]).abs
    body2 = (open[-2] - close[-2]).abs
    body3 = (open[-1] - close[-1]).abs
    avg_body = (body1 + body2 + body3) / 3

    consistent = (body1 - avg_body).abs < avg_body * 0.3 &&
                 (body2 - avg_body).abs < avg_body * 0.3 &&
                 (body3 - avg_body).abs < avg_body * 0.3

    if consistent
      puts "Candles are consistent - STRONG pattern"
    else
      puts "Candles vary in size - moderate pattern"
    end
  else
    puts "Three Black Crows but not after uptrend"
    puts "Lower reliability - may be continuation"
  end
end
```

## Example: Three Black Crows with Volume

```ruby
open, high, low, close, volume = load_ohlc_volume_data('TSLA')

pattern = SQA::TAI.cdl_3blackcrows(open, high, low, close)

if pattern.last == -100
  # Volume analysis for each crow
  vol_crow1 = volume[-3]
  vol_crow2 = volume[-2]
  vol_crow3 = volume[-1]
  avg_volume = volume[-20..-4].sum / 17.0  # Before pattern

  puts "Three Black Crows Volume Analysis:"
  puts "Crow 1 volume: #{vol_crow1.round(0)}"
  puts "Crow 2 volume: #{vol_crow2.round(0)}"
  puts "Crow 3 volume: #{vol_crow3.round(0)}"
  puts "Average volume (before): #{avg_volume.round(0)}"

  # Check for volume confirmation
  vol_increasing = vol_crow2 > vol_crow1 && vol_crow3 > vol_crow2
  high_vol = vol_crow1 > avg_volume && vol_crow2 > avg_volume && vol_crow3 > avg_volume

  if vol_increasing && high_vol
    puts "\nEXCELLENT: Increasing volume on all three crows"
    puts "High conviction selling - VERY STRONG pattern"
  elsif high_vol
    puts "\nGOOD: High volume on all crows"
    puts "Strong selling pressure"
  elsif vol_increasing
    puts "\nDECENT: Volume increasing"
    puts "Building selling momentum"
  else
    puts "\nWEAK: Low or decreasing volume"
    puts "Less reliable - may lack follow-through"
  end

  # Panic selling check
  if vol_crow3 > avg_volume * 2
    puts "\nWARNING: Panic selling on third crow"
    puts "May be climactic - watch for reversal"
  end
end
```

## Example: Three Black Crows at Resistance

```ruby
open, high, low, close = load_ohlc_data('MSFT')

pattern = SQA::TAI.cdl_3blackcrows(open, high, low, close)

# Find resistance
resistance = close[-120..-1].max
prior_high = high[-4]

if pattern.last == -100
  # Check if pattern formed at/near resistance
  at_resistance = (prior_high - resistance).abs < resistance * 0.02

  if at_resistance
    puts "Three Black Crows AT RESISTANCE!"
    puts "Resistance: #{resistance.round(2)}"
    puts "Pattern started near: #{prior_high.round(2)}"
    puts "Current price: #{close.last.round(2)}"
    puts "\nFailed breakout or resistance rejection"
    puts "VERY HIGH PROBABILITY reversal"

    # Calculate potential downside
    support = close[-60..-1].min
    potential_move = ((close.last - support) / close.last * 100).round(2)
    puts "Potential move to support: #{potential_move}%"
  else
    distance = ((prior_high - resistance) / resistance * 100).round(2)
    puts "Three Black Crows #{distance}% from resistance"
    puts "Moderate setup"
  end
end
```

## Example: Three Black Crows with RSI

```ruby
open, high, low, close = load_ohlc_data('NVDA')

pattern = SQA::TAI.cdl_3blackcrows(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last == -100
  rsi_before = rsi[-4]   # Before pattern
  rsi_current = rsi.last  # After pattern

  puts "Three Black Crows with RSI:"
  puts "RSI before pattern: #{rsi_before.round(2)}"
  puts "Current RSI: #{rsi_current.round(2)}"
  puts "RSI change: #{(rsi_current - rsi_before).round(2)}"

  if rsi_before > 70
    puts "\nPattern formed from OVERBOUGHT"
    puts "Classic reversal from extremes"
    puts "STRONG bearish signal"
  elsif rsi_before > 60
    puts "\nPattern formed from elevated RSI"
    puts "Good reversal setup"
  end

  # Check for oversold
  if rsi_current < 30
    puts "\nWARNING: Now oversold"
    puts "May see bounce - consider waiting"
  elsif rsi_current < 40
    puts "\nApproaching oversold - monitor closely"
  else
    puts "\nRoom to fall - RSI not oversold yet"
  end
end
```

## Trading Strategies

### Entry Rules

#### Conservative Entry (Recommended)
```ruby
# Wait for confirmation candle after pattern
if pattern[-2] == -100  # Pattern completed two candles ago
  if close[-1] < close[-2] || close.last < close[-1]
    puts "Three Black Crows CONFIRMED"
    entry = close.last
    puts "Enter SHORT at #{entry.round(2)}"
  else
    puts "Waiting for confirmation - price trying to recover"
  end
end
```

#### Aggressive Entry
```ruby
# Enter immediately on pattern completion
if pattern.last == -100
  entry = close.last
  puts "Three Black Crows completed - Enter SHORT"
  puts "Entry: #{entry.round(2)}"
  puts "Note: Higher risk without confirmation"
end
```

#### Pullback Entry
```ruby
# Wait for pullback to pattern area
if pattern[-3] == -100  # Pattern 3 candles ago
  pattern_high = [high[-3], high[-2], high[-1]].max

  if close.last > close[-1] && close.last < pattern_high
    puts "Pullback to pattern resistance"
    puts "Enter SHORT at #{close.last.round(2)}"
    puts "Lower risk entry point"
  end
end
```

### Stop Loss Placement

```ruby
if pattern.last == -100
  # Stop above pattern high
  pattern_high = [high[-3], high[-2], high[-1]].max
  stop = pattern_high * 1.01  # 1% buffer

  puts "Stop loss: #{stop.round(2)}"
  puts "Rationale: Above pattern high - invalidates bearish setup"

  # Alternative: Tighter stop above first candle
  tight_stop = high[-3] * 1.005  # 0.5% buffer
  puts "Tighter stop: #{tight_stop.round(2)} (higher risk)"

  # Calculate risk
  entry = close.last
  risk = stop - entry
  risk_percent = (risk / entry * 100).round(2)
  puts "Risk: $#{risk.round(2)} (#{risk_percent}%)"
end
```

### Profit Targets

```ruby
if pattern.last == -100
  entry = close.last
  stop = [high[-3], high[-2], high[-1]].max * 1.01
  risk = stop - entry

  # Risk-based targets
  target_1 = entry - (risk * 2)    # 2:1 R:R
  target_2 = entry - (risk * 3)    # 3:1 R:R
  target_3 = entry - (risk * 5)    # 5:1 R:R

  puts "Risk-Based Targets:"
  puts "T1 (2:1): #{target_1.round(2)}"
  puts "T2 (3:1): #{target_2.round(2)}"
  puts "T3 (5:1): #{target_3.round(2)}"

  # Support-based target
  support = close[-120..-1].min
  puts "\nSupport target: #{support.round(2)}"

  # Moving average target
  sma_50 = SQA::TAI.sma(close, period: 50)
  puts "50 SMA target: #{sma_50.last.round(2)}"
end
```

## Example: Complete Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('GOOGL')

pattern = SQA::TAI.cdl_3blackcrows(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern.last == -100
  puts "Three Black Crows Pattern Analysis"
  puts "=" * 60

  # 1. Trend context
  was_uptrend = close[-4] > sma_50[-4] && sma_50[-4] > sma_200[-4]

  # 2. Resistance check
  resistance = close[-120..-1].max
  high_before = high[-4]
  near_resistance = (high_before - resistance).abs < resistance * 0.03

  # 3. RSI analysis
  rsi_before = rsi[-4]
  rsi_overbought = rsi_before > 60

  # 4. Volume analysis
  avg_vol = volume[-20..-4].sum / 17.0
  vol_crows = [volume[-3], volume[-2], volume[-1]]
  high_volume = vol_crows.all? { |v| v > avg_vol }
  vol_increasing = vol_crows[-1] > vol_crows[-2] && vol_crows[-2] > vol_crows[-1]

  # 5. Candle quality
  body1 = (open[-3] - close[-3]).abs
  body2 = (open[-2] - close[-2]).abs
  body3 = (open[-1] - close[-1]).abs
  bodies = [body1, body2, body3]
  avg_body = bodies.sum / 3.0

  long_bodies = bodies.all? { |b| b > close[-4] * 0.02 }  # At least 2% bodies
  consistent = bodies.all? { |b| (b - avg_body).abs < avg_body * 0.4 }

  # 6. Shadow analysis
  shadow1_up = high[-3] - [open[-3], close[-3]].max
  shadow2_up = high[-2] - [open[-2], close[-2]].max
  shadow3_up = high[-1] - [open[-1], close[-1]].max

  minimal_shadows = [shadow1_up, shadow2_up, shadow3_up].all? { |s| s < avg_body * 0.3 }

  # 7. Progressive decline
  proper_opens = open[-2] < close[-3] && open[-2] > close[-3] - body1 &&
                 open[-1] < close[-2] && open[-1] > close[-2] - body2
  progressive_closes = close[-2] < close[-3] && close[-1] < close[-2]

  # Calculate score
  score = 0
  score += 2 if was_uptrend           # Critical
  score += 2 if near_resistance       # Very important
  score += 1 if rsi_overbought
  score += 1 if high_volume
  score += 1 if long_bodies
  score += 1 if consistent
  score += 1 if minimal_shadows
  score += 1 if proper_opens && progressive_closes

  puts "Quality Checks:"
  puts "1. Uptrend context: #{was_uptrend} #{was_uptrend ? '✓✓' : '✗✗'}"
  puts "2. Near resistance: #{near_resistance} #{near_resistance ? '✓✓' : '✗'}"
  puts "3. RSI overbought (#{rsi_before.round(2)}): #{rsi_overbought} #{rsi_overbought ? '✓' : '✗'}"
  puts "4. High volume: #{high_volume} #{high_volume ? '✓' : '✗'}"
  puts "5. Long bodies: #{long_bodies} #{long_bodies ? '✓' : '✗'}"
  puts "6. Consistent size: #{consistent} #{consistent ? '✓' : '✗'}"
  puts "7. Minimal shadows: #{minimal_shadows} #{minimal_shadows ? '✓' : '✗'}"
  puts "8. Proper formation: #{proper_opens && progressive_closes} #{proper_opens && progressive_closes ? '✓' : '✗'}"
  puts "\nTotal Score: #{score}/10"

  if score >= 7
    # Calculate trade parameters
    entry = close.last
    pattern_high = [high[-3], high[-2], high[-1]].max
    stop = pattern_high * 1.01
    risk = stop - entry

    # Find support for target
    support = close[-120..-1].min
    target_support = support
    target_rr3 = entry - (risk * 3)

    target = [target_support, target_rr3].max  # Use closer target
    reward = entry - target
    rr_ratio = (reward / risk).round(1)

    puts "\n*** EXCELLENT SHORT SETUP ***"
    puts "-" * 60
    puts "Entry: $#{entry.round(2)}"
    puts "Stop: $#{stop.round(2)} (above pattern high)"
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
- **At resistance**: 80-88% success rate
- **With volume**: 72-82% success rate
- **After strong uptrend**: 75-85% success rate

### Average Move
- **Initial decline**: 8-18% from pattern high
- **Major reversals**: 25-45% decline
- **Time to target**: 5-20 candles (varies by timeframe)
- **Follow-through**: 70% show continued weakness

## Best Practices

### Do's
1. Wait for established uptrend before taking signal
2. Verify all three candles have substantial bodies
3. Check for minimal upper shadows (strong selling)
4. Look for increasing or consistently high volume
5. Trade near resistance for best results
6. Confirm with RSI overbought conditions
7. Use proper stop loss above pattern high
8. Scale out at multiple targets
9. Look for consistent candle sizes
10. Verify proper candle progression (opens within bodies)

### Don'ts
1. Don't trade in existing downtrend (not a reversal there)
2. Don't ignore volume (critical confirmation)
3. Don't trade with long upper shadows (shows buying interest)
4. Don't enter without stop loss
5. Don't ignore overall market conditions
6. Don't trade if candles are tiny (weak pattern)
7. Don't chase if you missed entry
8. Don't confuse with ordinary decline
9. Don't trade if RSI already oversold
10. Don't risk more than 1-2% account

## Common Mistakes

1. **Trading in downtrend**: Pattern needs uptrend for reversal validity
2. **Ignoring candle quality**: Bodies must be long and consistent
3. **Poor stop placement**: Must protect above pattern high
4. **No volume confirmation**: High volume = high conviction
5. **Entering too late**: Best entry is at/near pattern completion
6. **Ignoring shadows**: Long upper shadows = buying pressure
7. **Wrong timeframe**: More reliable on daily/weekly charts

## Related Patterns

### Similar Bearish Patterns
- [Two Crows](cdl_2crows.md) - Two candle bearish reversal
- [Advance Block](cdl_advanceblock.md) - Three-candle topping
- [Evening Star](cdl_eveningstar.md) - Three-candle reversal with star
- [Dark Cloud Cover](cdl_darkcloudcover.md) - Two-candle reversal

### Opposite Pattern
- [Three White Soldiers](cdl_3whitesoldiers.md) - Bullish equivalent

### Component Patterns
- [Engulfing](cdl_engulfing.md) - May occur within the pattern
- [Marubozu](cdl_marubozu.md) - Long bodies with no shadows

## Pattern Variations

### Perfect Three Black Crows
- All three candles long and similar size
- Opens within previous bodies (no gaps)
- Closes at or near lows (minimal shadows)
- High volume on all three
- Appears at resistance after strong uptrend
- **Success Rate**: 80-85%

### Good Three Black Crows
- Long bodies with some variation
- Mostly minimal shadows
- Good volume
- Clear uptrend context
- **Success Rate**: 65-75%

### Weak Three Black Crows
- Variable candle sizes
- Long upper shadows (buying interest)
- Low volume
- No clear uptrend
- Not at resistance
- **Success Rate**: 45-55%

### Modified Patterns
- **Identical Three Crows**: All three nearly same size (stronger)
- **Deliberate Three Crows**: Small gaps between crows (weaker)

## Advanced Concepts

### Crow Quality Score
```ruby
def score_three_black_crows(open, high, low, close, volume)
  return 0 unless pattern.last == -100

  score = 0

  # Body length (0-2 points)
  bodies = [-3, -2, -1].map { |i| (open[i] - close[i]).abs }
  avg_body = bodies.sum / 3.0
  score += 2 if avg_body > close.last * 0.025  # 2.5%+ bodies
  score += 1 if avg_body > close.last * 0.015  # 1.5%+ bodies

  # Consistency (0-2 points)
  std_dev = Math.sqrt(bodies.sum { |b| (b - avg_body)**2 } / 3)
  score += 2 if std_dev < avg_body * 0.2   # Very consistent
  score += 1 if std_dev < avg_body * 0.4   # Fairly consistent

  # Shadow analysis (0-2 points)
  shadows = [-3, -2, -1].map { |i| high[i] - [open[i], close[i]].max }
  score += 2 if shadows.all? { |s| s < avg_body * 0.2 }
  score += 1 if shadows.all? { |s| s < avg_body * 0.4 }

  # Volume (0-2 points)
  avg_vol = volume[-20..-4].sum / 17.0
  crow_vols = volume[-3..-1]
  score += 2 if crow_vols.all? { |v| v > avg_vol * 1.3 }
  score += 1 if crow_vols.all? { |v| v > avg_vol }

  # Formation (0-2 points)
  proper_form = open[-2] < close[-3] && open[-2] > low[-3] &&
                open[-1] < close[-2] && open[-1] > low[-2] &&
                close[-2] < close[-3] && close[-1] < close[-2]
  score += 2 if proper_form

  score  # 0-10
end
```

## Key Takeaways

1. **Highly reliable** when all conditions present (uptrend, resistance, volume)
2. **Three is key** - shows persistence, not just one-off selling
3. **Context critical** - must follow uptrend for reversal signal
4. **Quality matters** - long consistent bodies with minimal shadows
5. **Volume confirms** - high volume shows conviction
6. **Stop protection** - always use stop above pattern high
7. **Patient entry** - best results with confirmation
8. **Multiple targets** - scale out as pattern plays out
9. **Risk management** - never risk more than 1-2% per trade
10. **Best at resistance** - failed breakout = strongest signal

## See Also

- [Three White Soldiers](cdl_3whitesoldiers.md) - Bullish counterpart
- [Two Crows](cdl_2crows.md) - Similar two-candle pattern
- [Evening Star](cdl_eveningstar.md) - Three-candle reversal
- [Advance Block](cdl_advanceblock.md) - Related topping pattern
- [Pattern Recognition Overview](../index.md)
- [Back to Indicators](../index.md)
