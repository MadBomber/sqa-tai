# Plus Directional Indicator (+DI)

The Plus Directional Indicator (+DI) measures the strength of upward price movement in a security. It's a core component of J. Welles Wilder's Directional Movement System and is used alongside the Minus Directional Indicator (-DI) and Average Directional Index (ADX) to identify trend direction and strength.

+DI quantifies bullish pressure by analyzing how much the current high exceeds the previous high, smoothed over a period. Values range from 0 to 100, with higher values indicating stronger upward movement.

## Formula

The +DI calculation involves:
1. Calculate +DM (Plus Directional Movement): Max(High - Previous High, 0)
2. Calculate True Range (TR)
3. Smooth +DM and TR over the period
4. +DI = (Smoothed +DM / Smoothed TR) * 100

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high prices |
| `low` | Array<Float> | Yes | - | Array of low prices |
| `close` | Array<Float> | Yes | - | Array of close prices |
| `period` | Integer | No | 14 | Number of periods for smoothing |

## Returns

Returns an array of +DI values ranging from 0 to 100. The first `period` values will be `nil`.

## Usage

```ruby
require 'sqa/tai'

high =  [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35, 49.92, 50.19, 50.12, 50.10, 50.00, 49.75, 49.80]
low =   [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03, 49.50, 49.87, 49.20, 49.00, 48.90, 49.00, 49.10]
close = [48.20, 48.61, 48.75, 48.63, 48.74, 49.03, 49.07, 49.32, 49.91, 50.13, 49.53, 49.50, 49.25, 49.20, 49.45]

plus_di = SQA::TAI.plus_di(high, low, close, period: 14)

puts "Current +DI: #{plus_di.last.round(2)}"
```

## Interpretation

| +DI Value | Upward Movement Strength |
|-----------|--------------------------|
| 0-15 | Very weak upward movement |
| 15-25 | Weak to moderate upward movement |
| 25-40 | Strong upward movement |
| 40-60 | Very strong upward movement |
| 60-100 | Extremely strong upward movement |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

**Key Signals:**
- **+DI > -DI**: Uptrend in control, bullish dominance
- **+DI < -DI**: Downtrend in control, bearish dominance
- **+DI crossover -DI**: Bullish signal (uptrend starting)
- **-DI crossover +DI**: Bearish signal (downtrend starting)
- **Rising +DI**: Increasing upward pressure
- **Falling +DI**: Decreasing upward pressure

## Example: Trend Direction Identification

```ruby
high, low, close = load_historical_ohlc('AAPL')

plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

current_plus = plus_di.last
current_minus = minus_di.last

if current_plus > current_minus
  spread = current_plus - current_minus
  puts "UPTREND: +DI (#{current_plus.round(2)}) > -DI (#{current_minus.round(2)})"
  puts "Bullish spread: #{spread.round(2)} points"

  if spread > 20
    puts "Strong uptrend dominance"
  elsif spread > 10
    puts "Moderate uptrend"
  else
    puts "Weak uptrend - watch for reversal"
  end
else
  spread = current_minus - current_plus
  puts "DOWNTREND: -DI (#{current_minus.round(2)}) > +DI (#{current_plus.round(2)})"
  puts "Bearish spread: #{spread.round(2)} points"
end
```

## Example: DI Crossover Strategy

```ruby
high, low, close = load_historical_ohlc('SPY')

plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

# Current values
current_plus = plus_di.last
current_minus = minus_di.last

# Previous values
prev_plus = plus_di[-2]
prev_minus = minus_di[-2]

# Detect crossovers
if prev_plus < prev_minus && current_plus > current_minus
  puts "BULLISH CROSSOVER DETECTED!"
  puts "+DI crossed above -DI"
  puts "+DI: #{prev_plus.round(2)} -> #{current_plus.round(2)}"
  puts "-DI: #{prev_minus.round(2)} -> #{current_minus.round(2)}"
  puts "SIGNAL: Enter long position"
elsif prev_plus > prev_minus && current_plus < current_minus
  puts "BEARISH CROSSOVER DETECTED!"
  puts "-DI crossed above +DI"
  puts "+DI: #{prev_plus.round(2)} -> #{current_plus.round(2)}"
  puts "-DI: #{prev_minus.round(2)} -> #{current_minus.round(2)}"
  puts "SIGNAL: Exit long or enter short position"
else
  puts "No crossover - trend continues"
  if current_plus > current_minus
    puts "Uptrend persists"
  else
    puts "Downtrend persists"
  end
end
```

## Example: +DI with ADX Confirmation

```ruby
high, low, close = load_historical_ohlc('MSFT')

plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)
adx = SQA::TAI.adx(high, low, close, period: 14)

current_plus = plus_di.last
current_minus = minus_di.last
current_adx = adx.last

puts "Plus DI: #{current_plus.round(2)}"
puts "Minus DI: #{current_minus.round(2)}"
puts "ADX: #{current_adx.round(2)}"

# Strong uptrend: +DI > -DI with strong ADX
if current_plus > current_minus && current_adx > 25
  di_spread = current_plus - current_minus
  puts "\nSTRONG CONFIRMED UPTREND"
  puts "DI Spread: #{di_spread.round(2)}"
  puts "Trend Strength: #{current_adx.round(2)}"
  puts "HIGH CONFIDENCE long opportunity"

# Weak uptrend: +DI > -DI but weak ADX
elsif current_plus > current_minus && current_adx < 25
  puts "\nWEAK UPTREND"
  puts "Bullish direction but low trend strength"
  puts "CAUTION: May be choppy or range-bound"

# Strong downtrend: -DI > +DI with strong ADX
elsif current_minus > current_plus && current_adx > 25
  puts "\nSTRONG CONFIRMED DOWNTREND"
  puts "Avoid longs, consider shorts"

else
  puts "\nWEAK/NO TREND"
  puts "Wait for clearer direction"
end
```

## Example: Uptrend Strength Analysis

```ruby
high, low, close = load_historical_ohlc('NVDA')

plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

current_plus = plus_di.last
prev_plus = plus_di[-5]

# Analyze +DI strength changes
di_change = current_plus - prev_plus

puts "Current +DI: #{current_plus.round(2)}"
puts "5 bars ago: #{prev_plus.round(2)}"
puts "Change: #{di_change.round(2)}"

case current_plus
when 0...15
  puts "\nUPWARD PRESSURE: Very Weak"
  puts "Minimal bullish momentum"
when 15...25
  puts "\nUPWARD PRESSURE: Weak to Moderate"
  puts "Some bullish activity present"
when 25...40
  puts "\nUPWARD PRESSURE: Strong"
  puts "Solid bullish momentum building"
  if di_change > 5
    puts "ACCELERATING - momentum increasing"
  end
when 40...60
  puts "\nUPWARD PRESSURE: Very Strong"
  puts "Powerful bullish trend in effect"
  if di_change > 0
    puts "Still strengthening"
  else
    puts "May be near peak strength"
  end
else
  puts "\nUPWARD PRESSURE: Extremely Strong"
  puts "Exceptional bullish momentum"
  puts "WARNING: Watch for exhaustion at extreme levels"
end

# Check if +DI is rising or falling
if di_change > 3
  puts "\nRapidly increasing upward pressure"
elsif di_change > 0
  puts "\nGradually increasing upward pressure"
elsif di_change > -3
  puts "\nGradually weakening upward pressure"
else
  puts "\nRapidly weakening upward pressure"
end
```

## Example: Multi-Timeframe +DI Analysis

```ruby
high, low, close = load_historical_ohlc('TSLA')

# Calculate different periods
plus_di_7 = SQA::TAI.plus_di(high, low, close, period: 7)
plus_di_14 = SQA::TAI.plus_di(high, low, close, period: 14)
plus_di_28 = SQA::TAI.plus_di(high, low, close, period: 28)

minus_di_7 = SQA::TAI.minus_di(high, low, close, period: 7)
minus_di_14 = SQA::TAI.minus_di(high, low, close, period: 14)
minus_di_28 = SQA::TAI.minus_di(high, low, close, period: 28)

puts "SHORT-TERM (7): +DI=#{plus_di_7.last.round(2)}, -DI=#{minus_di_7.last.round(2)}"
puts "STANDARD (14): +DI=#{plus_di_14.last.round(2)}, -DI=#{minus_di_14.last.round(2)}"
puts "LONG-TERM (28): +DI=#{plus_di_28.last.round(2)}, -DI=#{minus_di_28.last.round(2)}"

# All timeframes bullish = strong signal
if plus_di_7.last > minus_di_7.last &&
   plus_di_14.last > minus_di_14.last &&
   plus_di_28.last > minus_di_28.last
  puts "\nALL TIMEFRAMES BULLISH"
  puts "High confidence uptrend across all periods"
  puts "Strong buy signal"

# Mixed signals
elsif plus_di_7.last > minus_di_7.last &&
      plus_di_14.last < minus_di_14.last
  puts "\nSHORT-TERM BULLISH, LONGER-TERM BEARISH"
  puts "Possible counter-trend rally"
  puts "Use caution - may be temporary bounce"

elsif plus_di_28.last > minus_di_28.last &&
      plus_di_7.last < minus_di_7.last
  puts "\nLONG-TERM BULLISH, SHORT-TERM BEARISH"
  puts "Healthy pullback in uptrend"
  puts "Potential buying opportunity"
end
```

## Example: DI Extremes and Reversals

```ruby
high, low, close = load_historical_ohlc('QQQ')

plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

current_plus = plus_di.last
current_minus = minus_di.last
prev_plus = plus_di[-2]

# Extreme +DI values may signal exhaustion
if current_plus > 50
  puts "EXTREME +DI READING: #{current_plus.round(2)}"
  puts "Very strong uptrend but watch for exhaustion"

  if current_plus < prev_plus
    puts "WARNING: +DI falling from extreme high"
    puts "Possible trend exhaustion or reversal coming"
  end
end

# Very low +DI in downtrend
if current_plus < 10 && current_minus > 30
  puts "MINIMAL UPWARD PRESSURE"
  puts "+DI: #{current_plus.round(2)}, -DI: #{current_minus.round(2)}"
  puts "Strong downtrend with no bullish momentum"
  puts "Wait for +DI to start rising before considering longs"
end

# Recovery from low +DI
if prev_plus < 15 && current_plus > 20
  puts "BULLISH MOMENTUM AWAKENING"
  puts "+DI recovering from low levels"
  puts "Potential trend change developing"
end
```

## Example: Complete Directional Movement System

```ruby
high, low, close = load_historical_ohlc('SPY')

plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)
adx = SQA::TAI.adx(high, low, close, period: 14)

current_plus = plus_di.last
current_minus = minus_di.last
current_adx = adx.last

prev_plus = plus_di[-2]
prev_minus = minus_di[-2]
prev_adx = adx[-2]

puts "=== DIRECTIONAL MOVEMENT SYSTEM ANALYSIS ==="
puts "Plus DI: #{current_plus.round(2)}"
puts "Minus DI: #{current_minus.round(2)}"
puts "ADX: #{current_adx.round(2)}"
puts

# Determine trend quality and direction
if current_adx > 25
  if current_plus > current_minus
    spread = current_plus - current_minus
    puts "STATUS: Strong Uptrend"
    puts "Bullish DI spread: #{spread.round(2)}"

    # Check if trend is strengthening
    if current_adx > prev_adx
      puts "TREND: Strengthening (ADX rising)"
    else
      puts "TREND: Weakening (ADX falling)"
      puts "Consider taking profits"
    end

    # Entry/exit signals
    if prev_plus < prev_minus && current_plus > current_minus
      puts "SIGNAL: New buy signal (DI crossover)"
    elsif spread > 25
      puts "SIGNAL: Very strong - hold positions"
    end

  else
    spread = current_minus - current_plus
    puts "STATUS: Strong Downtrend"
    puts "Bearish DI spread: #{spread.round(2)}"
    puts "Avoid long positions"
  end

elsif current_adx < 20
  puts "STATUS: No Clear Trend (ADX < 20)"
  puts "Market is range-bound or choppy"

  if current_plus > current_minus
    puts "DIRECTION: Slightly bullish but weak"
  else
    puts "DIRECTION: Slightly bearish but weak"
  end

  puts "STRATEGY: Wait for trend development (ADX > 25)"

else
  puts "STATUS: Developing Trend (ADX 20-25)"
  puts "Watch for trend confirmation"

  if current_plus > current_minus && current_adx > prev_adx
    puts "SIGNAL: Potential uptrend developing"
    puts "Consider early entry if +DI continues rising"
  end
end
```

## Common Settings

| Period | Use Case |
|--------|----------|
| 7 | Short-term, sensitive to recent moves |
| 14 | Standard (Wilder's original) |
| 21 | Longer-term, smoother signals |
| 28 | Very long-term trend analysis |

## Trading Strategies

### 1. Basic DI Crossover
- **Buy**: When +DI crosses above -DI
- **Sell**: When -DI crosses above +DI
- **Best with**: ADX > 25 for confirmation

### 2. Strong Trend Filter
- Only trade in direction of higher DI
- Require minimum spread (e.g., 10 points)
- Use ADX to confirm strength

### 3. Extreme +DI Reversals
- Watch for +DI > 50 then declining
- May signal uptrend exhaustion
- Wait for -DI to cross over before shorting

### 4. Trend Continuation
- +DI > -DI and both rising = strong uptrend
- Add to positions on pullbacks
- Exit when -DI crosses above +DI

### 5. Multi-Timeframe Confirmation
- Align +DI on multiple periods
- All periods bullish = high confidence
- Mixed signals = wait for clarity

## Advanced Techniques

### 1. DI Spread Analysis
Monitor the difference between +DI and -DI:
- Spread > 20: Very strong trend
- Spread 10-20: Moderate trend
- Spread < 10: Weak trend or transition

### 2. +DI Momentum
Track rate of change in +DI:
- Rapidly rising +DI = accelerating uptrend
- Flat +DI = consolidating uptrend
- Falling +DI = weakening uptrend

### 3. DI Divergence
- Price makes higher high, +DI makes lower high = bearish divergence
- Price makes lower low, +DI makes higher low = bullish divergence

### 4. ADX/DI Matrix
| ADX | +DI vs -DI | Action |
|-----|------------|--------|
| > 25 | +DI > -DI | Strong buy |
| > 25 | -DI > +DI | Strong sell |
| < 20 | +DI > -DI | Weak buy, wait |
| < 20 | -DI > +DI | Weak sell, wait |

## Key Insights

1. **+DI measures buying pressure**, not price level
2. **Compare to -DI**, not to fixed thresholds
3. **Use with ADX** for complete picture
4. **Crossovers work best** in trending markets
5. **Extreme values** may signal exhaustion
6. **Rising +DI** shows strengthening bulls
7. **Falling +DI** shows weakening bulls

## Common Pitfalls

1. **Trading crossovers in choppy markets** - Always check ADX first
2. **Ignoring the spread** - Small spreads mean weak signals
3. **Using +DI alone** - Must compare to -DI for context
4. **Chasing extreme +DI** - High values may mean exhaustion
5. **Fixed thresholds** - +DI is relative to -DI, not absolute

## Related Indicators

- [ADX](adx.md) - Average Directional Index (trend strength)
- [MINUS_DI](minus_di.md) - Minus Directional Indicator (downward movement)
- [ADXR](adxr.md) - ADX Rating (smoothed ADX)
- [DX](dx.md) - Directional Movement Index
<!-- TODO: Create DMI documentation -->
- Complete Directional Movement Indicator (DMI)

## See Also

- [Back to Indicators](../index.md)
- [Momentum Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
<!-- TODO: Create example file -->
- Trend Following Strategies
