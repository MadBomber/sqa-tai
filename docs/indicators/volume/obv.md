# On Balance Volume (OBV)

On Balance Volume (OBV) is a momentum indicator that uses volume flow to predict changes in stock price. It adds volume on up days and subtracts volume on down days, creating a cumulative total.

## Usage

```ruby
require 'sqa/tai'

close = [45.15, 46.26, 46.50, 45.21, 44.34, 44.09, 45.42, 46.08, 47.03, 47.28]
volume = [2500, 3200, 2800, 4100, 3500, 3800, 4200, 3600, 5100, 4800]

# Calculate OBV
obv = SQA::TAI.obv(close, volume)

puts "Current OBV: #{obv.last.round(0)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `close` | Array | Yes | - | Array of closing prices |
| `volume` | Array | Yes | - | Array of volume values |

## Returns

Returns an array of cumulative OBV values.

## Formula

```
If Close > Previous Close:
  OBV = Previous OBV + Current Volume

If Close < Previous Close:
  OBV = Previous OBV - Current Volume

If Close = Previous Close:
  OBV = Previous OBV
```

## Interpretation

- **Rising OBV**: Buying pressure, accumulation
- **Falling OBV**: Selling pressure, distribution
- **OBV confirms price**: Healthy trend
- **OBV diverges from price**: Potential reversal

## Example: OBV Trend Analysis

```ruby
close, volume = load_price_volume_data('AAPL')

obv = SQA::TAI.obv(close, volume)

# Calculate OBV trend
obv_ma = SQA::TAI.sma(obv, period: 20)

current_obv = obv.last
current_obv_ma = obv_ma.last

if current_obv > current_obv_ma
  puts "OBV above 20-day MA: Bullish accumulation"
  if obv[-5..-1].all? { |v| v > obv[-6] }
    puts "OBV trending higher - strong buying pressure"
  end
elsif current_obv < current_obv_ma
  puts "OBV below 20-day MA: Bearish distribution"
  if obv[-5..-1].all? { |v| v < obv[-6] }
    puts "OBV trending lower - strong selling pressure"
  end
end
```

## Example: OBV Divergence

```ruby
close, volume = load_price_volume_data('TSLA')

obv = SQA::TAI.obv(close, volume)

# Find recent highs
price_high_1 = close[-30..-15].max
price_high_2 = close[-14..-1].max

price_high_1_idx = close[-30..-15].index(price_high_1) - 30
price_high_2_idx = close[-14..-1].index(price_high_2) - 14

obv_at_high_1 = obv[price_high_1_idx]
obv_at_high_2 = obv[price_high_2_idx]

# Bearish divergence
if price_high_2 > price_high_1 && obv_at_high_2 < obv_at_high_1
  puts "Bearish Divergence!"
  puts "Price: #{price_high_1.round(2)} -> #{price_high_2.round(2)} (higher high)"
  puts "OBV: #{obv_at_high_1.round(0)} -> #{obv_at_high_2.round(0)} (lower high)"
  puts "Selling pressure despite higher prices - potential reversal"
end

# Bullish divergence
price_low_1 = close[-30..-15].min
price_low_2 = close[-14..-1].min

price_low_1_idx = close[-30..-15].index(price_low_1) - 30
price_low_2_idx = close[-14..-1].index(price_low_2) - 14

obv_at_low_1 = obv[price_low_1_idx]
obv_at_low_2 = obv[price_low_2_idx]

if price_low_2 < price_low_1 && obv_at_low_2 > obv_at_low_1
  puts "Bullish Divergence!"
  puts "Price: #{price_low_1.round(2)} -> #{price_low_2.round(2)} (lower low)"
  puts "OBV: #{obv_at_low_1.round(0)} -> #{obv_at_low_2.round(0)} (higher low)"
  puts "Buying pressure despite lower prices - potential reversal"
end
```

## Example: OBV Breakout Confirmation

```ruby
close, volume = load_price_volume_data('MSFT')

obv = SQA::TAI.obv(close, volume)
price_high_52w = close[-252..-1].max

# Check if price breaking out
if close.last > price_high_52w
  # Is OBV also breaking out?
  obv_high_52w = obv[-252..-1].max

  if obv.last > obv_high_52w
    puts "Confirmed Breakout!"
    puts "Both price and OBV at new highs"
    puts "Strong buying pressure supports breakout"
  else
    puts "Weak Breakout"
    puts "Price at new high but OBV is not"
    puts "Lack of volume confirmation - be cautious"
  end
end
```

## Example: Volume Accumulation/Distribution

```ruby
close, volume = load_price_volume_data('NVDA')

obv = SQA::TAI.obv(close, volume)

# Compare OBV change with price change
lookback = 20
obv_change = obv.last - obv[-lookback]
price_change = close.last - close[-lookback]
price_change_pct = (price_change / close[-lookback]) * 100

puts "#{lookback}-day Price Change: #{price_change_pct.round(2)}%"
puts "#{lookback}-day OBV Change: #{obv_change.round(0)}"

if price_change > 0 && obv_change > 0
  puts "Price and OBV both rising - healthy uptrend"
elsif price_change > 0 && obv_change < 0
  puts "Price rising but OBV falling - weak advance, possible distribution"
elsif price_change < 0 && obv_change > 0
  puts "Price falling but OBV rising - possible accumulation"
elsif price_change < 0 && obv_change < 0
  puts "Price and OBV both falling - confirmed downtrend"
end
```

## Trading Strategies

### 1. OBV Trend Following
```ruby
# Buy when OBV crosses above its MA
# Sell when OBV crosses below its MA
```

### 2. Divergence Trading
```ruby
# Bullish divergence: Price lower, OBV higher
# Bearish divergence: Price higher, OBV lower
```

### 3. Breakout Confirmation
```ruby
# Only trade breakouts confirmed by OBV
```

### 4. Volume Trend Analysis
```ruby
# Rising OBV = Accumulation
# Falling OBV = Distribution
```

## Key Concepts

### Accumulation Phase
- Price flat or slightly up
- OBV rising
- Smart money buying

### Distribution Phase
- Price flat or slightly down
- OBV falling
- Smart money selling

### Confirmation
- Price and OBV move together
- Trend is healthy

### Divergence
- Price and OBV move apart
- Warning of potential reversal

## Example: Complete OBV Analysis

```ruby
close, volume = load_price_volume_data('GOOGL')

obv = SQA::TAI.obv(close, volume)
obv_ma_20 = SQA::TAI.sma(obv, period: 20)
obv_ma_50 = SQA::TAI.sma(obv, period: 50)

current_obv = obv.last
current_price = close.last

# Trend direction
obv_trend = if current_obv > obv_ma_20.last && obv_ma_20.last > obv_ma_50.last
  "Strong Bullish"
elsif current_obv < obv_ma_20.last && obv_ma_20.last < obv_ma_50.last
  "Strong Bearish"
else
  "Neutral/Transitioning"
end

# Recent momentum
obv_5day_change = obv.last - obv[-5]
obv_momentum = obv_5day_change > 0 ? "Increasing" : "Decreasing"

puts "OBV Analysis:"
puts "Current OBV: #{current_obv.round(0)}"
puts "Trend: #{obv_trend}"
puts "5-day Momentum: #{obv_momentum}"

# Divergence check
price_trend = close[-20..-1].each_cons(2).count { |a, b| b > a }
obv_trend_count = obv[-20..-1].each_cons(2).count { |a, b| b > a }

if (price_trend > 15 && obv_trend_count < 10) ||
   (price_trend < 5 && obv_trend_count > 10)
  puts "Warning: Potential divergence detected"
end
```

## Limitations

- OBV is cumulative and can't be compared across stocks
- Doesn't show volume intensity (10% move on low volume = 1% move on high volume)
- Subject to false signals in choppy markets
- No standardized overbought/oversold levels

## Advantages

- Simple and easy to understand
- Excellent for spotting divergences
- Works well for confirmation
- Applicable to all timeframes

## Related Indicators

- [Chaikin A/D Line (AD)](ad.md) - Similar volume indicator
- [MACD](../momentum/macd.md) - Often used together
- [RSI](../momentum/rsi.md) - Combine for confirmation

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Volume Analysis Example](../../examples/trend-analysis.md)
