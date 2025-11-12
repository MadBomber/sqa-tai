# Price Transform Indicators

Price transform indicators create simplified or alternative representations of price data by combining OHLC values in different ways. These transformed prices can reduce noise and provide clearer signals for trend analysis and trading decisions.

## Overview

Price transform indicators help traders:
- **Reduce Market Noise**: Smooth out erratic price movements
- **Identify True Price Levels**: Focus on representative price points
- **Simplify Analysis**: Use single values instead of full OHLC bars
- **Improve Indicator Accuracy**: Feed cleaner data to other indicators

## Available Price Transform Indicators

### [Average Price (AVGPRICE)](avgprice.md)
Simple average of open, high, low, and close prices.

```ruby
avg_price = SQA::TAI.avgprice(open, high, low, close)
```

**Key Features**:
- Equal weighting of all four price points
- Smooths price action
- Useful as base for other calculations

**Formula**: `(Open + High + Low + Close) / 4`

### [Median Price (MEDPRICE)](medprice.md)
Midpoint of the high-low range for each period.

```ruby
med_price = SQA::TAI.medprice(high, low)
```

**Key Features**:
- Focuses on trading range midpoint
- Ignores open and close
- Good for range-bound markets

**Formula**: `(High + Low) / 2`

### [Typical Price (TYPPRICE)](typprice.md)
Weighted average emphasizing the high, low, and close.

```ruby
typ_price = SQA::TAI.typprice(high, low, close)
```

**Key Features**:
- Most commonly used transform
- Represents "typical" trading activity
- Used in many volume-weighted indicators

**Formula**: `(High + Low + Close) / 3`

### [Weighted Close Price (WCLPRICE)](wclprice.md)
Price transform giving extra weight to the closing price.

```ruby
wcl_price = SQA::TAI.wclprice(high, low, close)
```

**Key Features**:
- Double weights the close
- Emphasizes where price actually settled
- Preferred when close is most important

**Formula**: `(High + Low + Close + Close) / 4`

## Common Usage Patterns

### Basic Price Transformation

```ruby
require 'sqa/tai'

# Load OHLC data
open, high, low, close = load_ohlc('AAPL')

# Calculate all price transforms
avg_price = SQA::TAI.avgprice(open, high, low, close)
med_price = SQA::TAI.medprice(high, low)
typ_price = SQA::TAI.typprice(high, low, close)
wcl_price = SQA::TAI.wclprice(high, low, close)

puts "Current Price Analysis:"
puts "Close: $#{close.last.round(2)}"
puts "Average Price: $#{avg_price.last.round(2)}"
puts "Median Price: $#{med_price.last.round(2)}"
puts "Typical Price: $#{typ_price.last.round(2)}"
puts "Weighted Close: $#{wcl_price.last.round(2)}"
```

### Using Transforms with Moving Averages

```ruby
require 'sqa/tai'

high, low, close = load_hlc('MSFT')

# Calculate typical price
typical = SQA::TAI.typprice(high, low, close)

# Use typical price for moving averages
sma_typical = SQA::TAI.sma(typical, period: 20)
ema_typical = SQA::TAI.ema(typical, period: 20)

# Compare with standard close-based MA
sma_close = SQA::TAI.sma(close, period: 20)

puts "Typical Price MA: $#{sma_typical.last.round(2)}"
puts "Close Price MA: $#{sma_close.last.round(2)}"
puts "Difference: $#{(sma_typical.last - sma_close.last).round(2)}"
```

### Volatility Analysis with Median Price

```ruby
require 'sqa/tai'

high, low, close = load_hlc('TSLA')

# Calculate median price and standard close
med_price = SQA::TAI.medprice(high, low)

# Calculate distance from median
deviation = close.zip(med_price).map { |c, m| ((c - m) / m * 100).round(2) }

puts "Close vs Median Price Analysis:"
puts "Current close deviation: #{deviation.last}%"

if deviation.last.abs > 2.0
  puts "Price extended from range midpoint"
  puts deviation.last > 0 ? "Trading near high" : "Trading near low"
else
  puts "Price balanced around range midpoint"
end
```

### Choosing the Right Transform

```ruby
require 'sqa/tai'

open, high, low, close = load_ohlc('NVDA')

# Different scenarios call for different transforms

# Scenario 1: Trend following (emphasize close)
wcl = SQA::TAI.wclprice(high, low, close)
trend_signal = SQA::TAI.ema(wcl, period: 20)

# Scenario 2: Range trading (emphasize midpoint)
med = SQA::TAI.medprice(high, low)
range_signal = SQA::TAI.sma(med, period: 20)

# Scenario 3: Volume analysis (use typical)
typ = SQA::TAI.typprice(high, low, close)
# typ commonly used with volume indicators

puts "Transform Selection Guide:"
puts "Weighted Close (trend): $#{wcl.last.round(2)}"
puts "Median (range): $#{med.last.round(2)}"
puts "Typical (volume): $#{typ.last.round(2)}"
```

## Comparison of Price Transforms

| Transform | Inputs | Weights | Best For |
|-----------|--------|---------|----------|
| AVGPRICE | OHLC | All equal | General smoothing |
| MEDPRICE | HL | Equal | Range trading |
| TYPPRICE | HLC | Equal | Volume analysis |
| WCLPRICE | HLC | Close x2 | Trend following |

## Best Practices

### 1. Match Transform to Strategy

```ruby
# Trend following: Use WCLPRICE (emphasizes close)
# Range trading: Use MEDPRICE (emphasizes midpoint)
# Volume analysis: Use TYPPRICE (standard for volume)
# General purpose: Use AVGPRICE (balanced)
```

### 2. Consistency is Key

```ruby
# Use same transform throughout analysis
# Don't mix transforms in single strategy
# Backtest to find best transform for your style
```

### 3. Combine with Other Indicators

```ruby
# Transforms work best feeding other indicators
# RSI on typical price vs close price
# Moving averages on weighted close
# Bollinger Bands on median price
```

### 4. Consider Market Type

```ruby
# Trending markets: WCLPRICE or AVGPRICE
# Choppy markets: MEDPRICE
# High volume assets: TYPPRICE
```

## Example: Complete Transform Analysis

```ruby
require 'sqa/tai'

# Load data
open, high, low, close = load_ohlc('AAPL')

# Calculate all transforms
avg_price = SQA::TAI.avgprice(open, high, low, close)
med_price = SQA::TAI.medprice(high, low)
typ_price = SQA::TAI.typprice(high, low, close)
wcl_price = SQA::TAI.wclprice(high, low, close)

puts "Price Transform Analysis"
puts "=" * 50

# Current values
puts "\nCurrent Prices:"
puts "Close: $#{close.last.round(2)}"
puts "Average: $#{avg_price.last.round(2)}"
puts "Median: $#{med_price.last.round(2)}"
puts "Typical: $#{typ_price.last.round(2)}"
puts "Weighted Close: $#{wcl_price.last.round(2)}"

# Calculate relative positions
puts "\nRelative to Close:"
[
  ['Average', avg_price.last],
  ['Median', med_price.last],
  ['Typical', typ_price.last],
  ['Weighted', wcl_price.last]
].each do |name, value|
  diff = ((value - close.last) / close.last * 100).round(2)
  puts "#{name}: #{diff}%"
end

# Trend analysis using different transforms
puts "\nTrend Analysis (20-period SMA):"

sma_close = SQA::TAI.sma(close, period: 20)
sma_wcl = SQA::TAI.sma(wcl_price, period: 20)
sma_typ = SQA::TAI.sma(typ_price, period: 20)
sma_med = SQA::TAI.sma(med_price, period: 20)

[
  ['Close', close.last, sma_close.last],
  ['Weighted', wcl_price.last, sma_wcl.last],
  ['Typical', typ_price.last, sma_typ.last],
  ['Median', med_price.last, sma_med.last]
].each do |name, price, ma|
  trend = price > ma ? "Above" : "Below"
  pct = ((price - ma) / ma * 100).round(2)
  puts "#{name}: #{trend} MA by #{pct.abs}%"
end

# Volatility assessment
range_pct = ((high.last - low.last) / close.last * 100).round(2)
close_position = ((close.last - low.last) / (high.last - low.last) * 100).round(2)

puts "\nVolatility Assessment:"
puts "Daily Range: #{range_pct}%"
puts "Close Position in Range: #{close_position.round(0)}%"

if close_position > 70
  puts "Close near top of range - bullish"
elsif close_position < 30
  puts "Close near bottom of range - bearish"
else
  puts "Close near middle of range - neutral"
end

# Recommendation
puts "\nRecommended Transform:"
if range_pct > 3.0
  puts "High volatility - use MEDPRICE for stability"
elsif close_position > 60 || close_position < 40
  puts "Strong directional move - use WCLPRICE"
else
  puts "Balanced conditions - use TYPPRICE or AVGPRICE"
end
```

## Advanced Applications

### Custom Pivot Points

```ruby
# Traditional pivot uses typical price
typical = SQA::TAI.typprice(high, low, close)
pivot = typical.last

resistance1 = 2 * pivot - low.last
support1 = 2 * pivot - high.last

puts "Pivot: $#{pivot.round(2)}"
puts "R1: $#{resistance1.round(2)}"
puts "S1: $#{support1.round(2)}"
```

### Multi-Timeframe Transform Analysis

```ruby
# Daily typical price
daily_typ = SQA::TAI.typprice(daily_high, daily_low, daily_close)
daily_ma = SQA::TAI.sma(daily_typ, period: 50)

# Hourly typical price
hourly_typ = SQA::TAI.typprice(hourly_high, hourly_low, hourly_close)
hourly_ma = SQA::TAI.sma(hourly_typ, period: 20)

# Align timeframes
if hourly_typ.last > hourly_ma.last && daily_typ.last > daily_ma.last
  puts "Both timeframes bullish"
end
```

## See Also

- [Average Price (AVGPRICE)](avgprice.md)
- [Median Price (MEDPRICE)](medprice.md)
- [Typical Price (TYPPRICE)](typprice.md)
- [Weighted Close Price (WCLPRICE)](wclprice.md)
- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
