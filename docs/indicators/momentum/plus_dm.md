# Plus Directional Movement (PLUS_DM)

The Plus Directional Movement (PLUS_DM or +DM) is a component of J. Welles Wilder's Directional Movement System that measures the magnitude of upward price movement. It quantifies the raw upward directional force by comparing the current high to the previous high. PLUS_DM is a building block indicator used to calculate the Plus Directional Indicator (+DI), which is then used in the ADX system for trend analysis.

## Understanding Directional Movement

Directional Movement isolates the portion of price movement that is directional:

- **Plus Directional Movement (+DM)**: Measures upward movement when current high exceeds previous high
- **Minus Directional Movement (-DM)**: Measures downward movement when current low is below previous low
- When both occur, only the larger movement is counted
- When neither occurs (inside bar), directional movement is zero

The key concept is that +DM captures ONLY the upward component of price action, ignoring all other movement.

## Formula

```
+DM Calculation for each period:

up_move = current_high - previous_high
down_move = previous_low - current_low

If up_move > down_move AND up_move > 0:
  +DM = up_move
Else:
  +DM = 0

Smoothed +DM (over period N):
First value = Sum of first N raw +DM values
Subsequent values = Previous +DM - (Previous +DM / N) + Current raw +DM
```

The smoothing is critical - it creates a running sum that emphasizes recent directional movement while maintaining historical context.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high prices |
| `low` | Array<Float> | Yes | - | Array of low prices |
| `period` | Integer | No | 14 | Smoothing period for directional movement |

## Returns

Returns an array of smoothed +DM values. These are unbounded, price-based measurements that represent the cumulative upward directional pressure. The first `period` values will be `nil` as smoothing requires initialization.

## Usage

```ruby
require 'sqa/tai'

high = [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35, 49.92, 50.19,
        50.12, 50.10, 50.00, 49.75, 49.80, 50.00, 50.15, 50.30]

low = [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03, 49.50, 49.87,
       49.20, 49.00, 48.90, 49.00, 49.10, 49.20, 49.40, 49.60]

# Calculate 14-period +DM
plus_dm = SQA::TAI.plus_dm(high, low, period: 14)

puts "Current +DM: #{plus_dm.last.round(2)}"
```

## Interpretation

+DM values represent the strength of upward directional movement:

| Condition | Interpretation |
|-----------|----------------|
| High +DM values | Strong, persistent upward movement |
| Low +DM values | Weak upward movement or downward price action |
| +DM rising | Upward momentum increasing |
| +DM falling | Upward momentum decreasing |
| +DM near zero | Little to no upward directional force |

**Important**: +DM is NOT normalized and therefore:
- Values depend on the price scale of the security
- Cannot be compared across different securities
- Cannot be compared across different price ranges of the same security
- Should be normalized (converted to +DI) for practical trading use

## Relationship to +DI (Plus Directional Indicator)

+DM is the raw measurement that gets normalized into +DI:

```ruby
# +DM is the raw upward movement
plus_dm = SQA::TAI.plus_dm(high, low, close, period: 14)

# +DI normalizes it using ATR (Average True Range)
# Formula: +DI = (+DM / ATR) * 100
plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
```

The normalization by ATR makes +DI:
- Bounded between 0 and 100
- Comparable across different securities
- Comparable across different time periods
- More useful for trading decisions

## Example: Visualizing Raw Directional Movement

```ruby
high = [50.0, 51.0, 52.0, 51.5, 51.0, 52.5, 53.0, 52.5, 53.5, 54.0]
low = [49.0, 50.0, 51.0, 50.5, 49.5, 51.5, 52.0, 51.5, 52.5, 53.0]

plus_dm = SQA::TAI.plus_dm(high, low, period: 5)

puts "Understanding +DM calculation:"
puts "=" * 50

(5...high.length).each do |i|
  up_move = high[i] - high[i-1]
  down_move = low[i-1] - low[i]

  puts "\nBar #{i}:"
  puts "  High: #{high[i-1]} -> #{high[i]} (move: #{up_move > 0 ? '+' : ''}#{up_move.round(2)})"
  puts "  Low: #{low[i-1]} -> #{low[i]} (move: #{down_move > 0 ? '+' : ''}#{down_move.round(2)})"

  if up_move > down_move && up_move > 0
    puts "  +DM = #{up_move.round(2)} (upward movement dominates)"
  else
    puts "  +DM = 0 (downward movement dominates or no directional move)"
  end

  puts "  Smoothed +DM: #{plus_dm[i]&.round(2) || 'nil (warming up)'}"
end
```

## Example: Comparing +DM to -DM

```ruby
high, low = load_historical_data('SPY', fields: [:high, :low])

plus_dm = SQA::TAI.plus_dm(high, low, period: 14)
minus_dm = SQA::TAI.minus_dm(high, low, period: 14)

current_plus = plus_dm.last
current_minus = minus_dm.last

puts "Directional Movement Analysis:"
puts "=" * 50
puts "+DM: #{current_plus.round(2)}"
puts "-DM: #{current_minus.round(2)}"
puts ""

if current_plus > current_minus * 1.5
  puts "Strong upward directional bias"
  puts "+DM is #{((current_plus / current_minus - 1) * 100).round(0)}% larger than -DM"
  puts "Price action dominated by upward moves"
elsif current_minus > current_plus * 1.5
  puts "Strong downward directional bias"
  puts "-DM is #{((current_minus / current_plus - 1) * 100).round(0)}% larger than +DM"
  puts "Price action dominated by downward moves"
else
  puts "Balanced directional movement"
  puts "No clear directional dominance"
end
```

## Example: Why +DI is More Useful Than +DM

```ruby
# Compare two securities with different price scales
high_aapl = [150.0, 152.0, 154.0, 153.0, 155.0]  # $150 stock
low_aapl = [149.0, 150.5, 152.0, 151.0, 153.0]

high_tsla = [800.0, 810.0, 820.0, 815.0, 825.0]  # $800 stock
low_tsla = [795.0, 802.0, 812.0, 808.0, 818.0]

# Both stocks moving up similarly (percentage-wise)
# But +DM will be very different...

plus_dm_aapl = SQA::TAI.plus_dm(high_aapl, low_aapl, period: 3)
plus_dm_tsla = SQA::TAI.plus_dm(high_tsla, low_tsla, period: 3)

puts "Raw +DM Comparison:"
puts "AAPL +DM: #{plus_dm_aapl.last.round(2)}"
puts "TSLA +DM: #{plus_dm_tsla.last.round(2)}"
puts "Cannot compare directly - different price scales!"
puts ""

# To compare, we need +DI (normalized by ATR)
close_aapl = [149.5, 151.0, 153.0, 152.0, 154.0]
close_tsla = [797.5, 805.0, 815.0, 810.0, 820.0]

plus_di_aapl = SQA::TAI.plus_di(high_aapl, low_aapl, close_aapl, period: 3)
plus_di_tsla = SQA::TAI.plus_di(high_tsla, low_tsla, close_tsla, period: 3)

puts "Normalized +DI Comparison:"
puts "AAPL +DI: #{plus_di_aapl.last.round(2)}"
puts "TSLA +DI: #{plus_di_tsla.last.round(2)}"
puts "Now comparable - both on 0-100 scale!"
```

## Example: Building Block for ADX System

```ruby
high, low, close = load_historical_ohlc('MSFT')

# Step 1: Calculate raw directional movements
plus_dm = SQA::TAI.plus_dm(high, low, period: 14)
minus_dm = SQA::TAI.minus_dm(high, low, period: 14)

# Step 2: Normalize by ATR to get directional indicators
atr = SQA::TAI.atr(high, low, close, period: 14)
plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

# Step 3: Calculate DX and ADX for trend strength
adx = SQA::TAI.adx(high, low, close, period: 14)

puts "Complete ADX System Breakdown:"
puts "=" * 50
puts "Raw Movements:"
puts "  +DM: #{plus_dm.last.round(2)} (raw upward movement)"
puts "  -DM: #{minus_dm.last.round(2)} (raw downward movement)"
puts "  ATR: #{atr.last.round(2)} (volatility normalization factor)"
puts ""
puts "Normalized Indicators:"
puts "  +DI: #{plus_di.last.round(2)} (+DM/ATR * 100)"
puts "  -DI: #{minus_di.last.round(2)} (-DM/ATR * 100)"
puts ""
puts "Trend Strength:"
puts "  ADX: #{adx.last.round(2)}"
puts ""

# Interpretation
if adx.last > 25
  if plus_di.last > minus_di.last
    puts "STRONG UPTREND"
    puts "High +DM values driving the trend strength"
  else
    puts "STRONG DOWNTREND"
    puts "High -DM values driving the trend strength"
  end
else
  puts "WEAK/NO TREND"
  puts "Both +DM and -DM relatively balanced"
end
```

## Example: Directional Movement Divergence

```ruby
high, low, close = load_historical_ohlc('NVDA')

plus_dm = SQA::TAI.plus_dm(high, low, period: 14)

# Calculate price momentum
prices = close
price_change_20 = prices.last - prices[-20]

# Calculate +DM momentum
dm_change_20 = plus_dm.last - plus_dm[-20]

puts "Directional Movement Divergence Analysis:"
puts "=" * 50
puts "20-bar price change: #{price_change_20.round(2)}"
puts "20-bar +DM change: #{dm_change_20.round(2)}"
puts ""

if price_change_20 > 0 && dm_change_20 < 0
  puts "BEARISH DIVERGENCE"
  puts "Price making higher highs but +DM decreasing"
  puts "Upward momentum weakening - potential reversal"
elsif price_change_20 < 0 && dm_change_20 > 0
  puts "Interesting condition:"
  puts "Price falling but +DM rising"
  puts "May indicate slowing downtrend or consolidation"
elsif price_change_20 > 0 && dm_change_20 > 0
  puts "BULLISH CONFIRMATION"
  puts "Both price and +DM rising - strong uptrend"
end
```

## Example: Smoothing Effect Demonstration

```ruby
# Create volatile price data
high = [50, 52, 51, 54, 53, 56, 55, 58, 57, 60, 59, 62, 61, 64, 63]
low = [48, 50, 49, 52, 51, 54, 53, 56, 55, 58, 57, 60, 59, 62, 61]

# Compare different smoothing periods
plus_dm_5 = SQA::TAI.plus_dm(high, low, period: 5)
plus_dm_14 = SQA::TAI.plus_dm(high, low, period: 14)
plus_dm_28 = SQA::TAI.plus_dm(high, low, period: 28)

puts "Smoothing Period Comparison:"
puts "=" * 50
puts "5-period +DM: #{plus_dm_5.compact.last&.round(2) || 'warming up'}"
puts "14-period +DM: #{plus_dm_14.compact.last&.round(2) || 'warming up'}"
puts "28-period +DM: #{plus_dm_28.compact.last&.round(2) || 'warming up'}"
puts ""
puts "Shorter periods: More responsive, captures recent moves"
puts "Longer periods: Smoother, less affected by noise"
```

## Advanced Techniques

### 1. Directional Movement Ratio
Compare +DM to -DM to gauge directional bias:
```ruby
ratio = plus_dm.last / (plus_dm.last + minus_dm.last)
# ratio > 0.7: Strong upward bias
# ratio < 0.3: Strong downward bias
```

### 2. Rate of Change in +DM
Monitor how quickly +DM is changing:
```ruby
dm_roc = (plus_dm.last - plus_dm[-5]) / plus_dm[-5] * 100
# Rapid increases may signal momentum acceleration
```

### 3. Directional Movement Oscillator
Create an oscillator from +DM and -DM:
```ruby
dm_osc = plus_dm.last - minus_dm.last
# Positive: Upward bias, Negative: Downward bias
```

## Common Periods

| Period | Use Case |
|--------|----------|
| 7 | Short-term, more reactive to changes |
| 14 | Standard (Wilder's original) - balanced sensitivity |
| 21 | Medium-term, smoother trend identification |
| 28 | Long-term, filters out short-term noise |

## Key Concepts

### Why Smoothing Matters
The smoothing formula creates a running sum with exponential-like decay:
- Recent directional movement has more influence
- Historical movement gradually fades but isn't forgotten
- Creates continuity in the measurement
- Prevents whipsaws from single-bar movements

### Why Only the Larger Move Counts
When both upward and downward movement occur:
- Taking the larger ensures only true directional force is measured
- Prevents double-counting during volatile bars
- Focuses on the dominant directional component
- Aligns with Wilder's philosophy of isolating trend direction

### The Price Scale Problem
+DM values are in the same units as price:
- A $100 stock might have +DM of 2.0
- A $1000 stock might have +DM of 20.0
- Both could have identical percentage moves
- This is why +DI normalization is crucial for practical use

## When to Use +DM vs +DI

**Use +DM when:**
- Building custom indicators from raw directional movement
- Analyzing the directional movement calculation process
- Developing educational materials on ADX system
- Debugging or validating +DI calculations

**Use +DI when:**
- Making actual trading decisions
- Comparing across different securities
- Setting absolute threshold values (e.g., +DI > 25)
- Using in strategies with other normalized indicators

## Limitations

1. **Not Normalized**: Cannot be used for cross-security comparison
2. **Price-Scale Dependent**: Values change with stock splits, price level changes
3. **No Absolute Thresholds**: Cannot say "+DM > 5 is bullish" universally
4. **Lag**: Smoothing introduces lag, misses rapid reversals
5. **No Context**: Doesn't account for volatility differences

## Related Indicators

- [PLUS_DI](plus_di.md) - Normalized version of +DM (recommended for trading)
- [MINUS_DM](minus_dm.md) - Downward directional movement counterpart
- [MINUS_DI](minus_di.md) - Normalized downward directional indicator
- [ADX](adx.md) - Average Directional Index (trend strength)
- [ADXR](adxr.md) - ADX Rating (smoothed ADX)
- [DX](dx.md) - Directional Movement Index
- [ATR](../volatility/atr.md) - Average True Range (used for normalization)

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
<!-- TODO: Create guide file -->
- Understanding the ADX System
<!-- TODO: Create example file -->
- Directional Movement Trading
