# Three Outside Up/Down Pattern

The Three Outside Up/Down is a powerful three-candlestick reversal pattern that combines an engulfing pattern with a confirmation candle. It provides one of the most reliable reversal signals in candlestick analysis, appearing in both bullish (Three Outside Up) and bearish (Three Outside Down) forms.

## Pattern Type

- **Type**: Reversal (Both Bullish and Bearish)
- **Candles Required**: 3
- **Trend Context**: Bullish variant after downtrend, Bearish variant after uptrend
- **Reliability**: High (one of the most reliable reversal patterns)
- **Frequency**: Moderate (appears 2-4% of the time)

## Usage

```ruby
require 'sqa/tai'

open  = [102.0, 101.0, 99.0, 98.5, 100.0]
high  = [102.5, 101.5, 100.5, 100.0, 101.5]
low   = [100.5, 98.5, 97.5, 98.0, 99.5]
close = [101.0, 99.0, 100.5, 100.0, 101.0]

# Detect Three Outside pattern
pattern = SQA::TAI.cdl_3outside(open, high, low, close)

if pattern.last == 100
  puts "Three Outside Up - Strong bullish reversal!"
elsif pattern.last == -100
  puts "Three Outside Down - Strong bearish reversal!"
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
- **0**: No Three Outside pattern detected
- **+100**: Three Outside Up (bullish reversal signal)
- **-100**: Three Outside Down (bearish reversal signal)

## Pattern Recognition Rules

### Three Outside Up (Bullish - Three Candle Structure)

1. **First Candle**: Small bearish candle in downtrend
2. **Second Candle**: Large bullish candle that:
   - Opens below first candle's close
   - Closes above first candle's open
   - Completely engulfs first candle's body
   - Forms a bullish engulfing pattern
3. **Third Candle**: Another bullish candle that:
   - Closes higher than second candle's close
   - Confirms the reversal
   - Shows continued buying momentum

### Three Outside Down (Bearish - Three Candle Structure)

1. **First Candle**: Small bullish candle in uptrend
2. **Second Candle**: Large bearish candle that:
   - Opens above first candle's close
   - Closes below first candle's open
   - Completely engulfs first candle's body
   - Forms a bearish engulfing pattern
3. **Third Candle**: Another bearish candle that:
   - Closes lower than second candle's close
   - Confirms the reversal
   - Shows continued selling momentum

### Key Characteristics

- Combines engulfing pattern (candles 1-2) with confirmation (candle 3)
- Second candle shows strong momentum shift
- Third candle validates the reversal
- More reliable than simple engulfing due to confirmation
- Volume typically increases through the pattern
- "Outside" refers to second candle engulfing first

## Visual Pattern

```
Three Outside Up (in downtrend):

        [===]      Third candle (confirms, closes higher)
         | |
       [=====]     Second candle (engulfs first)
       |     |
     [==]          First candle (small bearish)
      ||

Three Outside Down (in uptrend):

     [==]          First candle (small bullish)
      ||
       |     |
       [=====]     Second candle (engulfs first)
         | |
        [===]      Third candle (confirms, closes lower)
```

## Interpretation

The Three Outside pattern signals reversal through:

1. **Initial Exhaustion**: First candle shows weakening trend
2. **Momentum Shift**: Second candle (engulfing) shows power reversal
3. **Confirmation**: Third candle validates new direction
4. **Psychological Shift**: Three consecutive moves establish new trend
5. **Reliability**: Confirmation reduces false signals significantly

### Reliability Factors

| Factor | Low Reliability | Medium Reliability | High Reliability |
|--------|----------------|-------------------|------------------|
| Trend Strength | Weak trend | Clear trend | Strong trend |
| Engulfment Size | Barely engulfs | Good engulfment | Deep engulfment |
| Third Candle | Small body | Medium body | Large body |
| Volume | Decreasing | Normal | Increasing |
| Location | Mid-chart | Near S/R | At major S/R level |
| Shadows | Long shadows | Normal | Minimal shadows |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Example: Three Outside Up in Context

```ruby
open, high, low, close = load_ohlc_data('AAPL')

pattern = SQA::TAI.cdl_3outside(open, high, low, close)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern.last == 100
  # Verify downtrend context
  was_downtrend = close[-4] < sma_50[-4] && sma_50[-4] < sma_200[-4]

  if was_downtrend
    puts "Three Outside Up after downtrend!"
    puts "HIGH PROBABILITY bullish reversal"

    # Analyze engulfment quality
    first_body = (close[-3] - open[-3]).abs
    second_body = (close[-2] - open[-2]).abs
    engulf_ratio = second_body / first_body

    puts "Engulfment ratio: #{engulf_ratio.round(2)}x"

    if engulf_ratio > 3.0
      puts "VERY STRONG engulfment"
    elsif engulf_ratio > 2.0
      puts "Strong engulfment"
    else
      puts "Moderate engulfment"
    end

    # Check confirmation quality
    third_gain = close.last - close[-2]
    third_percent = (third_gain / close[-2] * 100).round(2)

    puts "Third candle gain: #{third_percent}%"

    if third_percent > 2.0
      puts "STRONG confirmation"
    elsif third_percent > 0.5
      puts "Good confirmation"
    else
      puts "Weak confirmation - watch closely"
    end
  end
end
```

## Example: Three Outside Down with Volume

```ruby
open, high, low, close, volume = load_ohlc_volume_data('TSLA')

pattern = SQA::TAI.cdl_3outside(open, high, low, close)

if pattern.last == -100
  # Volume progression analysis
  vol1 = volume[-3]  # First candle
  vol2 = volume[-2]  # Engulfing candle
  vol3 = volume[-1]  # Confirmation candle
  avg_volume = volume[-20..-4].sum / 17.0

  puts "Three Outside Down Volume Analysis:"
  puts "First candle: #{vol1.round(0)}"
  puts "Engulfing: #{vol2.round(0)} (#{(vol2/vol1).round(2)}x)"
  puts "Confirmation: #{vol3.round(0)} (#{(vol3/vol1).round(2)}x)"
  puts "Average: #{avg_volume.round(0)}"

  # Check volume pattern
  volume_increasing = vol2 > vol1 && vol3 >= vol2
  above_average = vol2 > avg_volume && vol3 > avg_volume

  if volume_increasing && above_average
    puts "\nEXCELLENT: Increasing volume + above average"
    puts "High conviction reversal - VERY STRONG"
  elsif above_average
    puts "\nGOOD: Above average volume"
    puts "Strong reversal signal"
  elsif volume_increasing
    puts "\nDECENT: Volume trend correct"
    puts "Moderate signal"
  else
    puts "\nWEAK: Poor volume confirmation"
    puts "Lower reliability"
  end
end
```

## Example: Three Outside at Support/Resistance

```ruby
open, high, low, close = load_ohlc_data('MSFT')

pattern = SQA::TAI.cdl_3outside(open, high, low, close)

if pattern.last == 100
  # Find support
  support = close[-120..-1].min
  pattern_low = low[-3]  # First candle low

  distance = ((pattern_low - support).abs / support * 100).round(2)

  if distance < 2
    puts "Three Outside Up AT SUPPORT!"
    puts "Support: #{support.round(2)}"
    puts "Pattern low: #{pattern_low.round(2)}"
    puts "Distance: #{distance}%"
    puts "\nTextbook reversal from support"
    puts "VERY HIGH PROBABILITY"
  end

elsif pattern.last == -100
  # Find resistance
  resistance = close[-120..-1].max
  pattern_high = high[-3]  # First candle high

  distance = ((pattern_high - resistance).abs / resistance * 100).round(2)

  if distance < 2
    puts "Three Outside Down AT RESISTANCE!"
    puts "Resistance: #{resistance.round(2)}"
    puts "Pattern high: #{pattern_high.round(2)}"
    puts "Distance: #{distance}%"
    puts "\nTextbook reversal from resistance"
    puts "VERY HIGH PROBABILITY"
  end
end
```

## Example: Three Outside with RSI

```ruby
open, high, low, close = load_ohlc_data('NVDA')

pattern = SQA::TAI.cdl_3outside(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)

if pattern.last == 100
  rsi_before = rsi[-4]  # Before pattern
  rsi_current = rsi.last

  puts "Three Outside Up with RSI:"
  puts "RSI before pattern: #{rsi_before.round(2)}"
  puts "Current RSI: #{rsi_current.round(2)}"
  puts "RSI change: +#{(rsi_current - rsi_before).round(2)}"

  if rsi_before < 30
    puts "\nOVERSOLD reversal - EXCELLENT"
    puts "Classic bounce from extreme"
  elsif rsi_before < 40
    puts "\nDepressed RSI reversal - GOOD"
  end

  if rsi_current > 50
    puts "RSI crossed midpoint - momentum confirmed"
  end

elsif pattern.last == -100
  rsi_before = rsi[-4]
  rsi_current = rsi.last

  puts "Three Outside Down with RSI:"
  puts "RSI before pattern: #{rsi_before.round(2)}"
  puts "Current RSI: #{rsi_current.round(2)}"
  puts "RSI change: #{(rsi_current - rsi_before).round(2)}"

  if rsi_before > 70
    puts "\nOVERBOUGHT reversal - EXCELLENT"
    puts "Classic rejection from extreme"
  elsif rsi_before > 60
    puts "\nElevated RSI reversal - GOOD"
  end

  if rsi_current < 50
    puts "RSI crossed midpoint - momentum confirmed"
  end
end
```

## Trading Strategies

### Entry Rules

#### Conservative Entry (Recommended)
```ruby
# Wait for fourth candle confirmation
if pattern[-2] == 100  # Pattern two candles ago
  if close[-1] > close[-2] || close.last > close[-1]
    puts "Three Outside Up CONFIRMED"
    entry = close.last
    puts "Enter LONG at #{entry.round(2)}"
  end

elsif pattern[-2] == -100
  if close[-1] < close[-2] || close.last < close[-1]
    puts "Three Outside Down CONFIRMED"
    entry = close.last
    puts "Enter SHORT at #{entry.round(2)}"
  end
end
```

#### Aggressive Entry
```ruby
# Enter on pattern completion (third candle close)
if pattern.last == 100
  entry = close.last
  puts "Three Outside Up - Enter LONG"
  puts "Entry: #{entry.round(2)}"

elsif pattern.last == -100
  entry = close.last
  puts "Three Outside Down - Enter SHORT"
  puts "Entry: #{entry.round(2)}"
end
```

#### Pullback Entry
```ruby
# Wait for pullback to engulfing candle level
if pattern[-3] == 100  # Pattern 3 candles ago
  engulf_close = close[-2]

  if close.last < close[-1] && close.last > engulf_close * 0.99
    puts "Pullback to engulfing level - Enter LONG"
    puts "Entry: #{close.last.round(2)}"
  end
end
```

### Stop Loss Placement

```ruby
if pattern.last == 100
  # Stop below first candle's low
  stop = low[-3] * 0.99  # 1% buffer

  puts "Stop loss: #{stop.round(2)}"
  puts "Rationale: Below pattern low (first candle)"

  entry = close.last
  risk = entry - stop
  risk_percent = (risk / entry * 100).round(2)
  puts "Risk: $#{risk.round(2)} (#{risk_percent}%)"

elsif pattern.last == -100
  # Stop above first candle's high
  stop = high[-3] * 1.01  # 1% buffer

  puts "Stop loss: #{stop.round(2)}"
  puts "Rationale: Above pattern high (first candle)"

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
  stop = low[-3] * 0.99
  risk = entry - stop

  # Risk-based targets
  target_1 = entry + (risk * 2)    # 2:1 R:R
  target_2 = entry + (risk * 3)    # 3:1 R:R
  target_3 = entry + (risk * 4)    # 4:1 R:R

  puts "Long Targets:"
  puts "T1 (2:1): #{target_1.round(2)}"
  puts "T2 (3:1): #{target_2.round(2)}"
  puts "T3 (4:1): #{target_3.round(2)}"

  # Resistance-based
  resistance = close[-120..-1].max
  puts "Resistance: #{resistance.round(2)}"

elsif pattern.last == -100
  entry = close.last
  stop = high[-3] * 1.01
  risk = stop - entry

  target_1 = entry - (risk * 2)
  target_2 = entry - (risk * 3)
  target_3 = entry - (risk * 4)

  puts "Short Targets:"
  puts "T1 (2:1): #{target_1.round(2)}"
  puts "T2 (3:1): #{target_2.round(2)}"
  puts "T3 (4:1): #{target_3.round(2)}"

  # Support-based
  support = close[-120..-1].min
  puts "Support: #{support.round(2)}"
end
```

## Example: Complete Trading System

```ruby
open, high, low, close, volume = load_ohlc_volume_data('GOOGL')

pattern = SQA::TAI.cdl_3outside(open, high, low, close)
rsi = SQA::TAI.rsi(close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

if pattern.last != 0
  is_bullish = pattern.last == 100

  puts "Three Outside #{is_bullish ? 'UP' : 'DOWN'}"
  puts "=" * 60

  # 1. Trend verification
  if is_bullish
    trend_ok = close[-4] < sma_50[-4] && sma_50[-4] < sma_200[-4]
  else
    trend_ok = close[-4] > sma_50[-4] && sma_50[-4] > sma_200[-4]
  end

  # 2. Engulfment quality
  first_body = (close[-3] - open[-3]).abs
  second_body = (close[-2] - open[-2]).abs
  engulf_ratio = second_body / first_body
  strong_engulf = engulf_ratio > 2.0

  # 3. Full engulfment check
  if is_bullish
    full_engulf = close[-2] > open[-3] && open[-2] < close[-3]
  else
    full_engulf = close[-2] < open[-3] && open[-2] > close[-3]
  end

  # 4. Confirmation quality
  if is_bullish
    good_confirm = close.last > close[-2]
    strong_confirm = (close.last - close[-2]) > (close[-2] - close[-3]) * 0.3
  else
    good_confirm = close.last < close[-2]
    strong_confirm = (close[-2] - close.last) > (close[-3] - close[-2]) * 0.3
  end

  # 5. Volume analysis
  avg_vol = volume[-20..-4].sum / 17.0
  vol_engulf = volume[-2]
  vol_confirm = volume[-1]
  high_volume = vol_engulf > avg_vol * 1.3

  # 6. RSI confirmation
  rsi_before = rsi[-4]
  if is_bullish
    rsi_ok = rsi_before < 45
  else
    rsi_ok = rsi_before > 55
  end

  # 7. Support/Resistance
  if is_bullish
    support = close[-120..-1].min
    near_level = (low[-3] - support).abs < support * 0.03
  else
    resistance = close[-120..-1].max
    near_level = (high[-3] - resistance).abs < resistance * 0.03
  end

  # Calculate score
  score = 0
  score += 2 if trend_ok
  score += 2 if strong_engulf
  score += 1 if full_engulf
  score += 2 if strong_confirm
  score += 1 if high_volume
  score += 1 if rsi_ok
  score += 1 if near_level

  puts "Setup Quality:"
  puts "1. Trend context: #{trend_ok} #{trend_ok ? '✓✓' : '✗'}"
  puts "2. Strong engulf (#{engulf_ratio.round(2)}x): #{strong_engulf} #{strong_engulf ? '✓✓' : '✗'}"
  puts "3. Full engulfment: #{full_engulf} #{full_engulf ? '✓' : '✗'}"
  puts "4. Strong confirmation: #{strong_confirm} #{strong_confirm ? '✓✓' : '✗'}"
  puts "5. High volume: #{high_volume} #{high_volume ? '✓' : '✗'}"
  puts "6. RSI favorable: #{rsi_ok} #{rsi_ok ? '✓' : '✗'}"
  puts "7. Near S/R: #{near_level} #{near_level ? '✓' : '✗'}"
  puts "\nTotal Score: #{score}/10"

  if score >= 7
    entry = close.last
    if is_bullish
      stop = low[-3] * 0.99
      risk = entry - stop
      target = entry + (risk * 3)
    else
      stop = high[-3] * 1.01
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
    puts "Reward: $#{reward.round(2)}"
    puts "R:R: 1:#{rr_ratio}"

    # Position sizing
    account = 100000
    risk_amount = account * 0.015  # 1.5% risk
    shares = (risk_amount / risk).floor

    puts "\nPosition (1.5% risk):"
    puts "Shares: #{shares}"
    puts "Value: $#{(shares * entry).round(2)}"
    puts "Risk: $#{risk_amount.round(2)}"
    puts "Potential: $#{(shares * reward).round(2)}"

  elsif score >= 5
    puts "\nDECENT - Reduce position"
  else
    puts "\nWEAK - SKIP"
  end
end
```

## Pattern Statistics

### Frequency
- **Occurrence**: Moderate (2-4% of the time)
- **Best Timeframes**: Daily, Weekly
- **Markets**: All markets (stocks, forex, crypto, commodities)

### Success Rate
- **Perfect setup**: 78-85% success rate
- **Good setup**: 68-75% success rate
- **Average setup**: 58-68% success rate
- **At support/resistance**: 80-88% success rate
- **With volume**: 72-82% success rate

### Average Move
- **Initial move**: 6-18% from pattern
- **Major reversals**: 20-45%
- **Time to target**: 5-15 candles
- **Follow-through**: 70% show continuation

## Best Practices

### Do's
1. Verify proper trend before pattern
2. Confirm second candle fully engulfs first
3. Wait for third candle confirmation
4. Check volume increases through pattern
5. Trade near support/resistance
6. Use RSI for additional confirmation
7. Place stops beyond pattern extremes
8. Scale out at multiple targets
9. Look for increasing body sizes
10. Give pattern room to develop

### Don'ts
1. Don't trade without trend context
2. Don't ignore engulfment quality
3. Don't skip confirmation candle
4. Don't trade on low volume
5. Don't enter without stops
6. Don't confuse with simple engulfing
7. Don't chase after big move
8. Don't ignore broader market
9. Don't risk more than 2% account
10. Don't trade weak confirmations

## Common Mistakes

1. **Ignoring confirmation**: Third candle is critical
2. **Weak engulfment**: Second candle must fully engulf first
3. **Wrong trend**: Must have prior trend to reverse
4. **Poor stop placement**: Use pattern extremes
5. **No volume check**: Volume validates pattern
6. **Entering too early**: Wait for completion
7. **Missing context**: Support/resistance critical

## Related Patterns

### Similar Patterns
- [Engulfing](cdl_engulfing.md) - Two-candle version (first two candles)
- [Three Inside Up/Down](cdl_3inside.md) - Related three-candle pattern
- [Piercing Pattern](cdl_piercing.md) - Similar bullish signal
- [Dark Cloud Cover](cdl_darkcloudcover.md) - Similar bearish signal
- [Morning Star](cdl_morningstar.md) - Three-candle bullish reversal
- [Evening Star](cdl_eveningstar.md) - Three-candle bearish reversal

### Component Patterns
- [Engulfing](cdl_engulfing.md) - Core of pattern (candles 1-2)
- [Long Line](cdl_longline.md) - Second and third candles

## Pattern Variations

### Perfect Three Outside
- Clear trend before pattern
- Second candle deeply engulfs first (3x+)
- Third candle strong continuation
- High volume on candles 2 and 3
- At major support/resistance
- **Success Rate**: 82-88%

### Strong Three Outside
- Good trend context
- Solid engulfment (2x+)
- Decent confirmation
- Above average volume
- **Success Rate**: 70-78%

### Weak Three Outside
- Unclear trend
- Barely engulfs (1.2x)
- Weak confirmation
- Low volume
- **Success Rate**: 50-60%

## Key Takeaways

1. **High reliability** - Confirmation makes it superior to engulfing alone
2. **Complete pattern** - All three candles matter
3. **Trend context** - Must have trend to reverse
4. **Engulfment critical** - Second candle must fully engulf first
5. **Confirmation validates** - Third candle confirms reversal
6. **Volume confirms** - Should increase through pattern
7. **Support/resistance** - Best at technical levels
8. **Tight stops** - Risk well-defined at pattern extremes
9. **Good R:R** - Typically 1:3 or better possible
10. **Patient entry** - Wait for full pattern completion

## See Also

- [Engulfing](cdl_engulfing.md)
- [Three Inside Up/Down](cdl_3inside.md)
- [Piercing Pattern](cdl_piercing.md)
- [Dark Cloud Cover](cdl_darkcloudcover.md)
- [Morning Star](cdl_morningstar.md)
- [Pattern Recognition Overview](../index.md)
- [Back to Indicators](../index.md)
