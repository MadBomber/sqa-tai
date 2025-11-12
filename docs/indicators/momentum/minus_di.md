# Minus Directional Indicator (MINUS_DI)

The Minus Directional Indicator (-DI) measures the strength of downward price movement. It's a core component of J. Welles Wilder's Directional Movement System and is used in combination with the Plus Directional Indicator (+DI) and Average Directional Index (ADX) to identify trend direction and strength.

## Formula

-DI is calculated using the following steps:
1. Calculate -DM (Minus Directional Movement): Maximum of (Prior Low - Current Low, 0)
2. Calculate True Range (TR): Maximum of (High-Low, |High-Close|, |Low-Close|)
3. Smooth both -DM and TR over the period
4. -DI = (Smoothed -DM / Smoothed TR) * 100

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high prices |
| `low` | Array<Float> | Yes | - | Array of low prices |
| `close` | Array<Float> | Yes | - | Array of close prices |
| `period` | Integer | No | 14 | Number of periods for smoothing |

## Returns

Returns an array of -DI values ranging from 0 to 100. Higher values indicate stronger downward movement.

## Usage

```ruby
require 'sqa/tai'

high =  [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35, 49.92, 50.19, 50.12, 50.10, 50.00, 49.75, 49.80]
low =   [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03, 49.50, 49.87, 49.20, 49.00, 48.90, 49.00, 49.10]
close = [48.20, 48.61, 48.75, 48.63, 48.74, 49.03, 49.07, 49.32, 49.91, 50.13, 49.53, 49.50, 49.25, 49.20, 49.45]

minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

puts "Current -DI: #{minus_di.last.round(2)}"
```

## Interpretation

| -DI Value | Meaning |
|-----------|---------|
| 0-20 | Weak downward movement |
| 20-40 | Moderate downward pressure |
| 40-60 | Strong downward movement |
| 60-100 | Very strong downward movement |

### Key Signals

**-DI vs +DI Comparison:**
- **-DI > +DI**: Downtrend in control - bearish bias
- **-DI < +DI**: Uptrend in control - bullish bias
- **Crossovers**: Signal potential trend changes

**Important**: -DI shows directional strength, but use with ADX to confirm overall trend strength!

## Example: Directional Movement Analysis

```ruby
high, low, close = load_historical_ohlc('SPY')

plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

current_plus = plus_di.last
current_minus = minus_di.last

if current_minus > current_plus
  spread = current_minus - current_plus
  puts "DOWNTREND IN CONTROL"
  puts "-DI: #{current_minus.round(2)}, +DI: #{current_plus.round(2)}"
  puts "Spread: #{spread.round(2)} points"

  if spread > 20
    puts "Strong downtrend dominance"
  elsif spread > 10
    puts "Moderate downtrend"
  else
    puts "Weak downtrend - watch for reversal"
  end
else
  puts "UPTREND IN CONTROL"
  puts "+DI: #{current_plus.round(2)}, -DI: #{current_minus.round(2)}"
end
```

## Example: DI Crossover System

```ruby
high, low, close = load_historical_ohlc('AAPL')

plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

# Current values
current_plus = plus_di.last
current_minus = minus_di.last

# Previous values
prev_plus = plus_di[-2]
prev_minus = minus_di[-2]

# Detect crossovers
if current_minus > current_plus && prev_minus <= prev_plus
  puts "BEARISH CROSSOVER: -DI crossed above +DI"
  puts "-DI: #{current_minus.round(2)}, +DI: #{current_plus.round(2)}"
  puts "SELL SIGNAL - Downtrend starting"
elsif current_plus > current_minus && prev_plus <= prev_minus
  puts "BULLISH CROSSOVER: +DI crossed above -DI"
  puts "+DI: #{current_plus.round(2)}, -DI: #{current_minus.round(2)}"
  puts "BUY SIGNAL - Uptrend starting"
else
  puts "NO CROSSOVER"
  puts "Current: -DI: #{current_minus.round(2)}, +DI: #{current_plus.round(2)}"
end
```

## Example: Complete Directional Movement System

```ruby
high, low, close = load_historical_ohlc('MSFT')

adx = SQA::TAI.adx(high, low, close, period: 14)
plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

current_adx = adx.last
current_plus = plus_di.last
current_minus = minus_di.last

# Wilder's Directional Movement System
puts "=== DIRECTIONAL MOVEMENT SYSTEM ==="
puts "ADX: #{current_adx.round(2)}"
puts "+DI: #{current_plus.round(2)}"
puts "-DI: #{current_minus.round(2)}"
puts ""

if current_adx > 25
  # Strong trend exists
  if current_minus > current_plus
    puts "STRONG DOWNTREND"
    puts "Strategy: Short or avoid long positions"
    puts "Confirmation: -DI (#{current_minus.round(2)}) > +DI (#{current_plus.round(2)})"
    puts "Trend Strength: ADX #{current_adx.round(2)}"
  else
    puts "STRONG UPTREND"
    puts "Strategy: Long positions favored"
    puts "Confirmation: +DI (#{current_plus.round(2)}) > -DI (#{current_minus.round(2)})"
    puts "Trend Strength: ADX #{current_adx.round(2)}"
  end
elsif current_adx > 20
  # Developing trend
  if current_minus > current_plus
    puts "DEVELOPING DOWNTREND"
    puts "Watch for ADX rise to confirm"
  else
    puts "DEVELOPING UPTREND"
    puts "Watch for ADX rise to confirm"
  end
else
  # Weak/no trend
  puts "WEAK TREND / RANGE-BOUND"
  puts "Avoid directional strategies"
  puts "DI values: -DI: #{current_minus.round(2)}, +DI: #{current_plus.round(2)}"
end
```

## Example: -DI Trend Strength

```ruby
high, low, close = load_historical_ohlc('TSLA')
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

current_di = minus_di.last
di_5_bars_ago = minus_di[-5]

change = current_di - di_5_bars_ago

puts "-DI Analysis:"
puts "Current: #{current_di.round(2)}"
puts "5 bars ago: #{di_5_bars_ago.round(2)}"
puts "Change: #{change > 0 ? '+' : ''}#{change.round(2)}"
puts ""

if current_di > 40
  if change > 5
    puts "STRONG & RISING downward pressure"
    puts "Downtrend accelerating"
  elsif change < -5
    puts "STRONG but WEAKENING downward pressure"
    puts "Potential trend reversal ahead"
  else
    puts "STRONG downward pressure (stable)"
  end
elsif current_di > 25
  puts "MODERATE downward pressure"
  puts change > 0 ? "Building momentum" : "Losing momentum"
else
  puts "WEAK downward pressure"
  puts "Limited downside strength"
end
```

## Example: DI Extremes and Reversals

```ruby
high, low, close = load_historical_ohlc('SPY')

plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

# Look for extreme readings
recent_minus_di = minus_di.last(20)
max_minus_di = recent_minus_di.max
current_minus = minus_di.last
current_plus = plus_di.last

if current_minus > 60
  puts "EXTREME -DI READING: #{current_minus.round(2)}"
  puts "Very strong downtrend - watch for exhaustion"

  # Check if starting to decline from extreme
  if current_minus < max_minus_di - 5
    puts "WARNING: -DI falling from extreme high"
    puts "Possible downtrend exhaustion"
    puts "Consider reducing short exposure"
  end
elsif current_minus < 15 && current_plus > 30
  puts "VERY LOW -DI: #{current_minus.round(2)}"
  puts "Minimal downward pressure"
  puts "Strong uptrend likely (+DI: #{current_plus.round(2)})"
end
```

## Example: -DI with Moving Average Filter

```ruby
high, low, close = load_historical_ohlc('AAPL')

minus_di = SQA::TAI.minus_di(high, low, close, period: 14)
plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
sma_50 = SQA::TAI.sma(close, period: 50)
sma_200 = SQA::TAI.sma(close, period: 200)

current_price = close.last
current_minus = minus_di.last
current_plus = plus_di.last

# Determine overall trend from moving averages
major_trend = sma_50.last > sma_200.last ? "UP" : "DOWN"

puts "Major Trend (MA): #{major_trend}"
puts "Price: #{current_price.round(2)}"
puts "-DI: #{current_minus.round(2)}, +DI: #{current_plus.round(2)}"
puts ""

if major_trend == "DOWN"
  # In downtrend - look for -DI confirmation
  if current_minus > current_plus
    puts "CONFIRMED DOWNTREND"
    puts "Both MA and DI show downtrend"
    puts "High-probability short setup"
  else
    puts "DIVERGENCE: MA shows down, but +DI > -DI"
    puts "Possible trend reversal developing"
    puts "Wait for confirmation"
  end
else
  # In uptrend
  if current_minus > current_plus
    puts "DIVERGENCE: MA shows up, but -DI > +DI"
    puts "Uptrend may be weakening"
    puts "Caution with new longs"
  else
    puts "CONFIRMED UPTREND"
    puts "Continue with trend-following strategy"
  end
end
```

## Common Settings

| Period | Use Case |
|--------|----------|
| 7 | Short-term, more sensitive to changes |
| 14 | Standard (Wilder's original recommendation) |
| 21 | Longer-term, smoother signals |
| 28 | Very long-term trend analysis |

## Trading Strategies

### 1. Basic DI Crossover
- **Sell**: -DI crosses above +DI
- **Buy**: +DI crosses above -DI
- **Filter**: Only trade when ADX > 20

### 2. DI Extreme Reversal
- Watch for -DI > 60 (extreme downtrend)
- Wait for -DI to start declining
- Buy when +DI crosses above falling -DI

### 3. DI Spread
- Measure spread between -DI and +DI
- Spread > 20: Very strong directional bias
- Spread < 5: Weak trend, avoid directional trades

### 4. DI with ADX Confirmation
- **Strong Downtrend**: -DI > +DI AND ADX > 25
- **Developing Downtrend**: -DI > +DI AND ADX rising
- **Weakening Downtrend**: -DI > +DI BUT ADX falling

## Advanced Techniques

### 1. DI Divergence
- Price makes lower low, but -DI makes lower high
- Suggests weakening downtrend
- Early reversal signal

### 2. DI Clustering
- When -DI and +DI are very close (<5 points apart)
- Indicates consolidation/range-bound market
- Wait for clear separation before trading

### 3. DI Momentum
- Track rate of change in -DI
- Rising -DI = building downward momentum
- Falling -DI = weakening downward pressure

## Related Indicators

- [ADX](adx.md) - Average Directional Index (trend strength)
- [PLUS_DI](plus_di.md) - Plus Directional Indicator (upward movement)
- [ADXR](adxr.md) - ADX Rating
- [DX](dx.md) - Directional Movement Index

## See Also

- [Back to Indicators](../index.md)
- [Momentum Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
