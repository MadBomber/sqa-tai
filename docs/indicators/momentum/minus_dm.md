# Minus Directional Movement (MINUS_DM)

The Minus Directional Movement (MINUS_DM) indicator measures the raw magnitude of downward price movement between periods. It is a foundational component of J. Welles Wilder's Directional Movement System and serves as the building block for calculating the Minus Directional Indicator (-DI). Unlike -DI which normalizes the movement relative to volatility, MINUS_DM provides the absolute downward movement in price units.

## Formula

MINUS_DM measures the downward movement between consecutive periods:

1. Calculate potential downward move: Low(previous) - Low(current)
2. Calculate potential upward move: High(current) - High(previous)
3. MINUS_DM = Low(previous) - Low(current) IF:
   - Downward move > Upward move, AND
   - Downward move > 0
4. Otherwise MINUS_DM = 0
5. Apply smoothing over the period (typically 14)

The smoothed MINUS_DM is then used in the -DI calculation:
-DI = (MINUS_DM / ATR) * 100

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high prices |
| `low` | Array<Float> | Yes | - | Array of low prices |
| `period` | Integer | No | 14 | Smoothing period (Wilder's default) |

## Returns

Returns an array of MINUS_DM values in price units. Values are unbounded and depend on the price scale of the instrument being analyzed.

## Usage

```ruby
require 'sqa/tai'

high = [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35, 49.92, 50.19, 50.12, 50.10, 50.00, 49.75, 49.80]
low =  [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03, 49.50, 49.87, 49.20, 49.00, 48.90, 49.00, 49.10]

# Calculate MINUS_DM
minus_dm = SQA::TAI.minus_dm(high, low, period: 14)

puts "Current MINUS_DM: #{minus_dm.last.round(2)}"
```

## Interpretation

| MINUS_DM Value | Interpretation |
|----------------|----------------|
| High values | Large downward movements occurring |
| Low values | Small or no downward movements |
| 0 | No downward directional movement |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

**Important**: MINUS_DM is measured in price units and is NOT normalized. A MINUS_DM of 2.50 means different things for a $10 stock versus a $1000 stock. For normalized comparisons, use -DI instead.

## Understanding Raw vs Normalized Movement

### MINUS_DM (Raw Movement)
- Measured in actual price units (dollars, points, etc.)
- Unbounded - depends on price scale
- Example: $2.50 downward movement
- Not comparable across different instruments or time periods

### MINUS_DI (Normalized Movement)
- Normalized by dividing by ATR (Average True Range)
- Expressed as percentage: (MINUS_DM / ATR) * 100
- Bounded between 0 and 100
- Comparable across instruments and timeframes
- Accounts for current volatility

## Example: Raw vs Normalized Comparison

```ruby
high =  [100.50, 101.20, 100.80, 99.50, 98.75, 99.20, 100.10, 99.90, 98.50, 97.80]
low =   [99.20, 100.10, 99.30, 98.10, 97.50, 98.30, 99.20, 98.60, 97.20, 96.50]
close = [100.00, 100.50, 99.80, 98.50, 98.00, 98.80, 99.70, 99.00, 97.80, 97.20]

# Raw downward movement (in price units)
minus_dm = SQA::TAI.minus_dm(high, low, period: 14)

# Normalized downward movement (as percentage of volatility)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

puts "MINUS_DM (raw): $#{minus_dm.last.round(2)}"
puts "MINUS_DI (normalized): #{minus_di.last.round(2)}%"
puts ""
puts "Raw value depends on price scale"
puts "Normalized value accounts for volatility"
```

## Example: Building Block for -DI

```ruby
high =  [50.19, 50.12, 50.10, 50.00, 49.75, 49.80, 49.95, 50.20, 50.50, 50.75]
low =   [49.87, 49.20, 49.00, 48.90, 49.00, 49.10, 49.30, 49.80, 50.10, 50.30]
close = [50.13, 49.53, 49.50, 49.25, 49.20, 49.45, 49.70, 50.00, 50.35, 50.60]

# Component calculation
minus_dm = SQA::TAI.minus_dm(high, low, period: 14)
atr = SQA::TAI.atr(high, low, close, period: 14)

# Manual -DI calculation (for illustration)
manual_minus_di = (minus_dm.last / atr.last) * 100

# Compare with library -DI
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)

puts "MINUS_DM: #{minus_dm.last.round(4)}"
puts "ATR: #{atr.last.round(4)}"
puts "Manual -DI: #{manual_minus_di.round(2)}%"
puts "Library -DI: #{minus_di.last.round(2)}%"
puts ""
puts "MINUS_DM / ATR normalization makes -DI volatility-adjusted"
```

## Example: Comparing Instruments

```ruby
# Stock A: Low-priced stock ($10 range)
stock_a_high = [10.50, 10.75, 10.60, 10.40, 10.20, 10.30, 10.45]
stock_a_low =  [10.20, 10.40, 10.30, 10.10, 9.90, 10.00, 10.15]

# Stock B: High-priced stock ($500 range)
stock_b_high = [510.50, 512.75, 511.60, 509.40, 507.20, 508.30, 510.45]
stock_b_low =  [509.20, 510.40, 510.30, 508.10, 505.90, 506.00, 508.15]

minus_dm_a = SQA::TAI.minus_dm(stock_a_high, stock_a_low, period: 5)
minus_dm_b = SQA::TAI.minus_dm(stock_b_high, stock_b_low, period: 5)

puts "Stock A MINUS_DM: $#{minus_dm_a.last.round(2)}"
puts "Stock B MINUS_DM: $#{minus_dm_b.last.round(2)}"
puts ""
puts "Raw MINUS_DM values are NOT comparable across different price levels"
puts "Both stocks have similar percentage moves, but different MINUS_DM"
puts ""
puts "Solution: Use MINUS_DI for normalized comparison"
```

## Example: Directional Movement Analysis

```ruby
high = [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35, 49.92, 50.19,
        50.12, 50.10, 50.00, 49.75, 49.80, 49.95, 50.20, 50.50, 50.75, 51.00]
low =  [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03, 49.50, 49.87,
        49.20, 49.00, 48.90, 49.00, 49.10, 49.30, 49.80, 50.10, 50.30, 50.60]

# Compare upward vs downward movement
plus_dm = SQA::TAI.plus_dm(high, low, period: 14)
minus_dm = SQA::TAI.minus_dm(high, low, period: 14)

current_plus = plus_dm.last
current_minus = minus_dm.last

puts "PLUS_DM (upward movement): #{current_plus.round(2)}"
puts "MINUS_DM (downward movement): #{current_minus.round(2)}"
puts ""

if current_plus > current_minus
  puts "Upward directional movement is stronger"
  puts "Difference: #{(current_plus - current_minus).round(2)} price units"
elsif current_minus > current_plus
  puts "Downward directional movement is stronger"
  puts "Difference: #{(current_minus - current_plus).round(2)} price units"
else
  puts "Directional movements are balanced"
end
```

## Common Settings

| Period | Use Case |
|--------|----------|
| 14 | Standard (Wilder's original) |
| 7 | More responsive to recent moves |
| 21 | Smoother, longer-term perspective |

## When to Use MINUS_DM vs MINUS_DI

### Use MINUS_DM when:
- Implementing custom directional indicators
- Analyzing absolute movement magnitudes
- Debugging or understanding the calculation chain
- Educational/research purposes

### Use MINUS_DI when:
- Trading and signal generation
- Comparing different instruments
- Analyzing strength of downward movement
- Combining with other normalized indicators (ADX, DX)

### Recommendation
For most trading applications, use MINUS_DI (-DI) instead of MINUS_DM because:
1. Normalized for volatility comparison
2. Bounded range (0-100) easier to interpret
3. Comparable across instruments and timeframes
4. Integrates with ADX system for trend analysis

## Example: Complete Directional System

```ruby
high =  [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35, 49.92, 50.19,
         50.12, 50.10, 50.00, 49.75, 49.80, 49.95, 50.20, 50.50, 50.75, 51.00]
low =   [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03, 49.50, 49.87,
         49.20, 49.00, 48.90, 49.00, 49.10, 49.30, 49.80, 50.10, 50.30, 50.60]
close = [48.20, 48.61, 48.75, 48.63, 48.74, 49.03, 49.07, 49.32, 49.91, 50.13,
         49.53, 49.50, 49.25, 49.20, 49.45, 49.70, 50.00, 50.35, 50.60, 50.85]

# Building blocks (raw movement)
plus_dm = SQA::TAI.plus_dm(high, low, period: 14)
minus_dm = SQA::TAI.minus_dm(high, low, period: 14)
atr = SQA::TAI.atr(high, low, close, period: 14)

# Normalized indicators (for trading)
plus_di = SQA::TAI.plus_di(high, low, close, period: 14)
minus_di = SQA::TAI.minus_di(high, low, close, period: 14)
adx = SQA::TAI.adx(high, low, close, period: 14)

puts "=== Raw Components (Price Units) ==="
puts "PLUS_DM: #{plus_dm.last.round(4)}"
puts "MINUS_DM: #{minus_dm.last.round(4)}"
puts "ATR: #{atr.last.round(4)}"
puts ""

puts "=== Normalized Indicators (Percentage) ==="
puts "+DI: #{plus_di.last.round(2)}%"
puts "-DI: #{minus_di.last.round(2)}%"
puts "ADX: #{adx.last.round(2)}"
puts ""

# Trading logic uses normalized values
if adx.last > 25
  if plus_di.last > minus_di.last
    puts "STRONG UPTREND - Consider long positions"
  else
    puts "STRONG DOWNTREND - Consider short positions"
  end
else
  puts "WEAK TREND - Use range-trading strategies"
end
```

## Technical Notes

1. **Smoothing**: MINUS_DM uses Wilder's smoothing method
2. **Period Selection**: Default 14 balances responsiveness vs stability
3. **Directional Rules**: Only counts movement in one direction per period
4. **Zero Values**: MINUS_DM = 0 when upward move exceeds downward move
5. **Price Units**: Results are in the same units as input prices

## Relationship with Other Indicators

```
MINUS_DM (raw) → Used to calculate → MINUS_DI (normalized)
                                            ↓
PLUS_DM (raw) → Used to calculate → PLUS_DI (normalized) → DX → ADX
                                            ↓
                           ATR (volatility normalization)
```

## Related Indicators

- [MINUS_DI](minus_di.md) - Normalized version (recommended for trading)
- [PLUS_DM](plus_dm.md) - Upward directional movement
- [PLUS_DI](plus_di.md) - Plus Directional Indicator
- [ADX](adx.md) - Average Directional Index (trend strength)
- [DX](dx.md) - Directional Movement Index
- [ATR](../volatility/atr.md) - Average True Range (volatility measure)

## See Also

- [Back to Indicators](../index.md)
- [Momentum Indicators Overview](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
