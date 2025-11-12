# Typical Price (TYPPRICE)

The Typical Price is a price transformation that calculates a three-point average of the high, low, and close prices for each period. By giving equal weight to all three price points, it provides a more representative measure of price action than using the close alone. TYPPRICE smooths extreme price movements and is widely used as a preprocessor input for volume-weighted and momentum indicators.

## Formula

Typical Price = (High + Low + Close) / 3

This simple arithmetic mean treats each of the three price components equally:
- High: The period's maximum price
- Low: The period's minimum price
- Close: The period's final price

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high prices for each period |
| `low` | Array<Float> | Yes | - | Array of low prices for each period |
| `close` | Array<Float> | Yes | - | Array of close prices for each period |

## Returns

Returns an array of typical price values, one for each period. Each value represents the three-point average for that period.

## Usage

```ruby
require 'sqa/tai'

high =  [48.70, 48.72, 48.90, 48.87, 48.82]
low =   [47.79, 48.14, 48.39, 48.37, 48.24]
close = [48.20, 48.61, 48.75, 48.63, 48.74]

typprice = SQA::TAI.typprice(high, low, close)

puts "Current Typical Price: #{typprice.last.round(2)}"
# Output: Current Typical Price: 48.60
```

## Interpretation

The Typical Price provides a more balanced view of price action than using close prices alone:

| Characteristic | Interpretation |
|----------------|----------------|
| Equal weighting | Each price component (H, L, C) contributes 33.33% |
| Smoothing effect | Reduces impact of extreme highs or lows |
| Centered measure | Represents the "middle ground" of the period's action |
| Volume neutral | Does not incorporate volume data |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

### Why Use Typical Price?

1. **More Representative Than Close**: While the close is important, it's just one moment in time. The typical price captures the entire range of price movement.

2. **Reduces Noise**: By averaging three prices, extreme movements in any single component are smoothed out.

3. **Foundation for Other Indicators**: Many technical indicators use typical price as their base calculation, particularly volume-weighted indicators.

4. **Consistent Baseline**: Provides a standardized price reference that works across all markets and timeframes.

## Example: Comparing Price Measures

```ruby
high =  [50.00, 51.00, 49.50, 52.00, 51.50]
low =   [48.00, 49.00, 48.50, 50.00, 49.50]
close = [49.50, 50.50, 49.00, 51.50, 50.00]

typprice = SQA::TAI.typprice(high, low, close)
medprice = SQA::TAI.medprice(high, low)
wclprice = SQA::TAI.wclprice(high, low, close)

# Compare the different price measures
puts "Period | Close | Median | Typical | Weighted"
puts "-------|-------|--------|---------|----------"
close.each_with_index do |c, i|
  puts "  #{i+1}    | #{c}  | #{medprice[i].round(2)} | #{typprice[i].round(2)}  | #{wclprice[i].round(2)}"
end
```

## Example: Typical Price as Indicator Input

```ruby
# Using typical price for CCI calculation (built-in)
high, low, close = load_historical_ohlc('AAPL')
cci = SQA::TAI.cci(high, low, close, period: 14)

# Manual typical price calculation for custom indicators
typprice = SQA::TAI.typprice(high, low, close)

# Calculate simple moving average of typical price
tp_sma = SQA::TAI.sma(typprice, period: 20)

puts "Typical Price SMA(20): #{tp_sma.last.round(2)}"
```

## Example: Volume-Weighted Typical Price

```ruby
high, low, close, volume = load_ohlcv_data('SPY')

typprice = SQA::TAI.typprice(high, low, close)

# Calculate volume-weighted typical price (VWTP)
vwtp_sum = 0.0
volume_sum = 0.0

typprice.last(20).each_with_index do |tp, i|
  vwtp_sum += tp * volume[-(20-i)]
  volume_sum += volume[-(20-i)]
end

vwtp = vwtp_sum / volume_sum
puts "20-period Volume-Weighted Typical Price: #{vwtp.round(2)}"
```

## Example: Pivot Points Using Typical Price

```ruby
# Daily pivot point calculations using previous day's data
prev_high = 152.50
prev_low = 150.25
prev_close = 151.75

# Calculate typical price (pivot point)
pivot = (prev_high + prev_low + prev_close) / 3
puts "Pivot Point: #{pivot.round(2)}"

# Support and resistance levels
r1 = (2 * pivot) - prev_low
s1 = (2 * pivot) - prev_high
r2 = pivot + (prev_high - prev_low)
s2 = pivot - (prev_high - prev_low)

puts <<~LEVELS
  Support/Resistance Levels:
  R2: #{r2.round(2)}
  R1: #{r1.round(2)}
  PP: #{pivot.round(2)}
  S1: #{s1.round(2)}
  S2: #{s2.round(2)}
LEVELS
```

## Common Use Cases

### 1. Money Flow Index (MFI)
MFI uses typical price to calculate raw money flow:
```ruby
high, low, close, volume = load_ohlcv_data('MSFT')
mfi = SQA::TAI.mfi(high, low, close, volume, period: 14)
```

### 2. Commodity Channel Index (CCI)
CCI measures deviation from the mean typical price:
```ruby
high, low, close = load_historical_ohlc('GLD')
cci = SQA::TAI.cci(high, low, close, period: 20)
```

### 3. Custom Volume Analysis
Typical price provides a fair value for volume-weighted calculations:
```ruby
typprice = SQA::TAI.typprice(high, low, close)
money_flow = typprice.zip(volume).map { |tp, vol| tp * vol }
```

### 4. Intraday Pivot Points
Day traders use typical price for support/resistance levels:
```ruby
# Previous day's typical price becomes today's pivot
yesterday_tp = SQA::TAI.typprice([prev_high], [prev_low], [prev_close]).first
```

## Comparison with Other Price Transforms

| Transform | Formula | Weights | Use Case |
|-----------|---------|---------|----------|
| **TYPPRICE** | (H+L+C)/3 | Equal | Balanced representation, volume indicators |
| **MEDPRICE** | (H+L)/2 | H=50%, L=50% | Simple midpoint, excludes close |
| **WCLPRICE** | (H+L+2C)/4 | H=25%, L=25%, C=50% | Emphasizes closing price |
| **AVGPRICE** | (O+H+L+C)/4 | Equal | Includes opening price |

**When to Use TYPPRICE vs Alternatives:**

- **Use TYPPRICE** when you want equal weighting of high, low, and close
- **Use MEDPRICE** when you want a simple range midpoint without close bias
- **Use WCLPRICE** when you believe close is more significant than high/low
- **Use AVGPRICE** when you want to include the opening price

## Trading Considerations

### Advantages
- Mathematically simple and fast to calculate
- Provides balanced view of price action
- Standard input for many popular indicators
- Works well across all timeframes and markets
- Reduces impact of outlier prices

### Limitations
- Ignores opening price
- Does not account for volume
- Equal weighting may not reflect market reality
- Close price often considered most important
- Cannot capture intraday patterns

### Best Practices
1. Use as input to volume-weighted indicators
2. Apply to pivot point calculations
3. Smooth with moving averages for trend analysis
4. Compare with other price transforms for divergences
5. Consider timeframe - works well on all periods

## Related Indicators

### Price Transforms
- [AVGPRICE](avgprice.md) - Average Price (includes open)
- [MEDPRICE](medprice.md) - Median Price (excludes close)
- [WCLPRICE](wclprice.md) - Weighted Close Price (emphasizes close)

### Indicators Using TYPPRICE
- [CCI](../momentum/cci.md) - Commodity Channel Index
- [MFI](../momentum/mfi.md) - Money Flow Index
- Various pivot point systems
- Volume-weighted indicators

## See Also

- [Back to Indicators](../index.md)
- [Price Transform Overview](../index.md)
