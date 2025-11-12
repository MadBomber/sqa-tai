# Median Price (MEDPRICE)

The Median Price (MEDPRICE) is a price transformation that calculates the midpoint between the high and low prices for each period. Unlike the close price, which only captures the final transaction price, the median price represents the typical intraday midpoint, filtering out some noise while providing a balanced view of the trading range. It's commonly used as input to other technical indicators and for smoothing price data in analysis.

## Usage

```ruby
require 'sqa/tai'

high = [48.70, 48.72, 48.90, 48.87, 48.82]
low =  [47.79, 48.14, 48.39, 48.37, 48.24]

medprice = SQA::TAI.medprice(high, low)

puts "Current Median Price: #{medprice.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high prices for each period |
| `low` | Array<Float> | Yes | - | Array of low prices for each period |

## Returns

Returns an array of median price values, one for each period. No warmup period needed as this is a simple bar-by-bar calculation.

## Formula

```
Median Price = (High + Low) / 2
```

This formula calculates the arithmetic mean of the highest and lowest prices traded during each period, representing the midpoint of the trading range.

## Interpretation

| Concept | Description |
|---------|-------------|
| Typical Midpoint | Represents the average of extremes, smoothing intraday volatility |
| Range Center | Shows where price action centered during the period |
| Noise Filtering | Less affected by gap openings or volatile closes |
| Balance Point | Captures both buying and selling extremes equally |

The median price is particularly useful when:
- You want to reduce the impact of outlier closes
- Analyzing the typical price level for a period
- Building indicators that need smoothed price input
- Comparing price action across different securities

## Example: Basic MEDPRICE Calculation

```ruby
high =      [48.70, 48.72, 48.90, 48.87, 48.82]
low =       [47.79, 48.14, 48.39, 48.37, 48.24]
close =     [48.20, 48.61, 48.75, 48.63, 48.74]

medprice = SQA::TAI.medprice(high, low)

# Compare median price to close
puts "Period Analysis:"
medprice.each_with_index do |mp, i|
  difference = close[i] - mp
  position = difference > 0 ? "above" : "below"

  puts "Period #{i+1}:"
  puts "  High: #{high[i]}, Low: #{low[i]}, Close: #{close[i]}"
  puts "  Median Price: #{mp.round(2)}"
  puts "  Close is #{difference.abs.round(2)} #{position} median"
  puts "  #{difference > 0 ? 'Bullish close (upper half)' : 'Bearish close (lower half)'}"
  puts
end
```

## Example: MEDPRICE vs Close Price

```ruby
high_prices =  load_historical_data('AAPL', field: :high)
low_prices =   load_historical_data('AAPL', field: :low)
close_prices = load_historical_data('AAPL', field: :close)

medprice = SQA::TAI.medprice(high_prices, low_prices)

# Analyze where closes fall relative to median
recent_periods = 20
upper_half_closes = 0
lower_half_closes = 0

recent_periods.times do |i|
  index = -(i + 1)
  if close_prices[index] > medprice[index]
    upper_half_closes += 1
  else
    lower_half_closes += 1
  end
end

puts "Last #{recent_periods} periods:"
puts "Closes in upper half: #{upper_half_closes} (#{(upper_half_closes.to_f/recent_periods*100).round(1)}%)"
puts "Closes in lower half: #{lower_half_closes} (#{(lower_half_closes.to_f/recent_periods*100).round(1)}%)"

if upper_half_closes > lower_half_closes * 1.5
  puts "Strong bullish bias - closes consistently in upper range"
elsif lower_half_closes > upper_half_closes * 1.5
  puts "Strong bearish bias - closes consistently in lower range"
else
  puts "Balanced - no clear directional bias"
end
```

## Example: MEDPRICE as Moving Average Input

```ruby
high_prices = load_historical_data('MSFT', field: :high)
low_prices =  load_historical_data('MSFT', field: :low)
close_prices = load_historical_data('MSFT', field: :close)

# Compare different moving average inputs
ma_close = SQA::TAI.sma(close_prices, period: 20)

medprice = SQA::TAI.medprice(high_prices, low_prices)
ma_median = SQA::TAI.sma(medprice, period: 20)

current_close = close_prices.last
current_ma_close = ma_close.last
current_ma_median = ma_median.last

puts "Moving Average Comparison (20-period):"
puts "Price: #{current_close.round(2)}"
puts "MA of Close: #{current_ma_close.round(2)}"
puts "MA of Median: #{current_ma_median.round(2)}"
puts "Difference: #{(current_ma_close - current_ma_median).round(2)}"

# Median-based MA is often smoother and less affected by gaps
if (current_close - current_ma_median).abs < (current_close - current_ma_close).abs
  puts "MA of Median Price provides tighter support/resistance"
end
```

## Example: Support and Resistance Levels

```ruby
high_prices = load_historical_data('TSLA', field: :high)
low_prices =  load_historical_data('TSLA', field: :low)

medprice = SQA::TAI.medprice(high_prices, low_prices)

# Find recent pivot points using median price
lookback = 50
recent_medians = medprice[-lookback..-1]

# Calculate potential support/resistance zones
resistance_zone = recent_medians.max
support_zone = recent_medians.min
current_median = medprice.last

puts "Support/Resistance Analysis (#{lookback} periods):"
puts "Resistance (highest median): #{resistance_zone.round(2)}"
puts "Current Median Price: #{current_median.round(2)}"
puts "Support (lowest median): #{support_zone.round(2)}"

range = resistance_zone - support_zone
current_position = ((current_median - support_zone) / range * 100).round(1)

puts "Current position in range: #{current_position}%"

case current_position
when 0...25
  puts "Near support - potential bounce zone"
when 25...50
  puts "Lower half of range"
when 50...75
  puts "Upper half of range"
when 75..100
  puts "Near resistance - potential reversal zone"
end
```

## Example: Volume-Weighted Analysis

```ruby
high_prices =   load_historical_data('SPY', field: :high)
low_prices =    load_historical_data('SPY', field: :low)
close_prices =  load_historical_data('SPY', field: :close)
volume =        load_historical_data('SPY', field: :volume)

medprice = SQA::TAI.medprice(high_prices, low_prices)

# Calculate volume-weighted median price
lookback = 20
total_volume = 0
weighted_sum = 0

lookback.times do |i|
  index = -(i + 1)
  total_volume += volume[index]
  weighted_sum += medprice[index] * volume[index]
end

vwmp = weighted_sum / total_volume  # Volume-Weighted Median Price

current_close = close_prices.last
puts "Volume-Weighted Analysis (#{lookback} periods):"
puts "Current Close: #{current_close.round(2)}"
puts "Volume-Weighted Median Price: #{vwmp.round(2)}"

if current_close > vwmp
  puts "Price above VWMP - bullish positioning"
  puts "Distance: +#{((current_close - vwmp) / vwmp * 100).round(2)}%"
else
  puts "Price below VWMP - bearish positioning"
  puts "Distance: -#{((vwmp - current_close) / vwmp * 100).round(2)}%"
end
```

## When to Use MEDPRICE vs Close Price

### Use Median Price When:

1. **Reducing Gap Impact**: Median price ignores opening gaps, focusing on intraday range
2. **Smoothing Indicators**: Building moving averages or oscillators with less noise
3. **Range Analysis**: Studying where price action centers within each period
4. **Support/Resistance**: Identifying typical price levels for pivot points
5. **Volume Studies**: Creating volume-weighted price measures
6. **Commodity Trading**: Common in commodity markets where range matters more
7. **Intraday Analysis**: Understanding typical price levels within bars

### Use Close Price When:

1. **Momentum Analysis**: Close reflects final trader sentiment
2. **Trend Following**: Close shows direction of price resolution
3. **Pattern Recognition**: Most candlestick patterns rely on close
4. **Gap Trading**: Gaps are important signals in your strategy
5. **End-of-Day Systems**: Trading on daily close signals
6. **Market Sentiment**: Close shows who won the period (bulls or bears)
7. **Standard Indicators**: Most indicators expect close price input

### Key Differences:

| Aspect | Median Price | Close Price |
|--------|--------------|-------------|
| **Calculation** | (High + Low) / 2 | Last trade of period |
| **Sensitivity** | Less volatile | More volatile |
| **Gap Impact** | Not affected by gaps | Reflects gaps |
| **Use Case** | Smoothing, range analysis | Momentum, sentiment |
| **Noise Level** | Lower noise | Higher noise |
| **Trading Style** | Range trading, mean reversion | Trend following, breakouts |

## Example: Comparing Price Transforms

```ruby
high_prices =  load_historical_data('NVDA', field: :high)
low_prices =   load_historical_data('NVDA', field: :low)
close_prices = load_historical_data('NVDA', field: :close)

# Calculate all price transforms
medprice = SQA::TAI.medprice(high_prices, low_prices)
typprice = SQA::TAI.typprice(high_prices, low_prices, close_prices)
wclprice = SQA::TAI.wclprice(high_prices, low_prices, close_prices)

current_close = close_prices.last
current_med = medprice.last
current_typ = typprice.last
current_wcl = wclprice.last

puts "Price Transform Comparison:"
puts "Close Price:    #{current_close.round(2)}"
puts "Median Price:   #{current_med.round(2)} (high+low)/2"
puts "Typical Price:  #{current_typ.round(2)} (high+low+close)/3"
puts "Weighted Close: #{current_wcl.round(2)} (high+low+2*close)/4"
puts

# Analyze spreads
med_spread = (current_close - current_med).abs
typ_spread = (current_close - current_typ).abs
wcl_spread = (current_close - current_wcl).abs

puts "Distance from Close:"
puts "Median:   #{med_spread.round(2)} (#{(med_spread/current_close*100).round(2)}%)"
puts "Typical:  #{typ_spread.round(2)} (#{(typ_spread/current_close*100).round(2)}%)"
puts "Weighted: #{wcl_spread.round(2)} (#{(wcl_spread/current_close*100).round(2)}%)"
puts

# MEDPRICE has largest deviation potential (ignores close)
# WCLPRICE has smallest deviation (weighted toward close)
if med_spread > typ_spread * 1.5
  puts "Large median deviation suggests close near high or low extreme"
  if current_close > current_med
    puts "Close near high - strong buying"
  else
    puts "Close near low - strong selling"
  end
end
```

## Advanced Techniques

### 1. Median Price Channels
Create channels using median price moving averages:
- Upper channel: MA(Median) + N * ATR
- Lower channel: MA(Median) - N * ATR
- Smoother than close-based channels

### 2. Mean Reversion Trading
Median price naturally mean-reverts within ranges:
- Buy when close < median - threshold
- Sell when close > median + threshold
- Works well in ranging markets

### 3. Filtered Indicators
Use median price input for cleaner signals:
- RSI on median price (less whipsaw)
- MACD on median price (smoother crossovers)
- Bollinger Bands on median price (better range definition)

### 4. Intraday Position Analysis
Track where closes fall relative to median:
- Consistent upper-half closes = bullish
- Consistent lower-half closes = bearish
- Useful for confirming trend strength

## Common Settings

MEDPRICE has no period parameter - it's calculated bar-by-bar. However, when used as input to other indicators:

| Input Usage | Period | Use Case |
|-------------|--------|----------|
| SMA(MEDPRICE) | 10-20 | Short-term trend |
| SMA(MEDPRICE) | 50 | Intermediate trend |
| SMA(MEDPRICE) | 200 | Long-term trend |
| RSI(MEDPRICE) | 14 | Smoother momentum |
| BBANDS(MEDPRICE) | 20 | Range-based volatility |

## Advantages and Limitations

### Advantages:
- Simple, transparent calculation
- Filters gap-related noise
- Represents true intraday center
- Works well for range-based strategies
- Less affected by single-trade spikes
- Good input for volume-weighted studies

### Limitations:
- Ignores opening price completely
- Doesn't capture final sentiment (close)
- Less useful for momentum strategies
- May miss important closing patterns
- Not standard input for most indicators
- Less intuitive than close price

## Related Indicators

- [TYPPRICE](typprice.md) - Typical Price (includes close)
- [WCLPRICE](wclprice.md) - Weighted Close Price (emphasizes close)
- [AVGPRICE](avgprice.md) - Average Price (includes open)
- [SMA](../overlap/sma.md) - Often applied to median price
- [CCI](../momentum/cci.md) - Uses typical price (similar concept)

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
<!-- TODO: Create price transform index file -->
- Price Transform Overview
