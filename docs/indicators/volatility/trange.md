# True Range (TRANGE)

True Range measures the price volatility of an asset for a single period. It's the foundation for the Average True Range (ATR) indicator.

## Usage

```ruby
require 'sqa/tai'

# OHLC data required
high  = [46.08, 46.41, 46.46, 46.57, 46.50, 47.03]
low   = [44.61, 44.83, 45.64, 45.95, 46.02, 46.50]
close = [45.42, 45.84, 46.08, 46.46, 46.55, 47.03]

# Calculate True Range
trange = SQA::TAI.trange(high, low, close)

puts "Current True Range: #{trange.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array | Yes | - | Array of high prices |
| `low` | Array | Yes | - | Array of low prices |
| `close` | Array | Yes | - | Array of closing prices |

## Returns

Returns an array of True Range values. The first value will be `nil` (no previous close to compare).

## Formula

True Range is the greatest of:
1. Current High - Current Low
2. |Current High - Previous Close|
3. |Current Low - Previous Close|

```ruby
tr1 = high[i] - low[i]
tr2 = (high[i] - close[i-1]).abs
tr3 = (low[i] - close[i-1]).abs
true_range = [tr1, tr2, tr3].max
```

## Interpretation

- **Large True Range**: High volatility for that period
- **Small True Range**: Low volatility for that period
- **Increasing True Range**: Volatility expanding
- **Decreasing True Range**: Volatility contracting

## Why Use True Range?

Simple High-Low range doesn't account for gaps:

```ruby
# Example: Gap up opening

# Day 1: High=50, Low=48, Close=49
# Simple range = 2

# Day 2: High=55, Low=53, Close=54 (gap up from 49 to 53)
# Simple range = 2 (but price moved 6 points from previous close!)
# True Range = 6 (captures the gap)
```

## Example: Daily Volatility Analysis

```ruby
high, low, close = load_ohlc_data('AAPL')

trange = SQA::TAI.trange(high, low, close)

# Get recent true ranges
recent_tr = trange.compact.last(20)

avg_tr = recent_tr.sum / recent_tr.size
current_tr = trange.last

puts "Current True Range: $#{current_tr.round(2)}"
puts "20-day Average TR: $#{avg_tr.round(2)}"

if current_tr > avg_tr * 1.5
  puts "Today's range #{((current_tr / avg_tr - 1) * 100).round(0)}% above average"
  puts "Higher than normal volatility"
elsif current_tr < avg_tr * 0.5
  puts "Today's range #{((1 - current_tr / avg_tr) * 100).round(0)}% below average"
  puts "Lower than normal volatility"
end
```

## Example: Identifying Range Expansion

```ruby
high, low, close = load_ohlc_data('TSLA')

trange = SQA::TAI.trange(high, low, close)

# Look for range expansion days
(5...trange.length).each do |i|
  next if trange[i].nil?

  recent_avg = trange[(i-5)...i].compact.sum / 5.0

  if trange[i] > recent_avg * 2
    puts "Range expansion on day #{i}"
    puts "True Range: #{trange[i].round(2)} (5-day avg: #{recent_avg.round(2)})"
    puts "High: #{high[i]}, Low: #{low[i]}, Close: #{close[i]}"
  end
end
```

## Example: True Range vs Simple Range

```ruby
high, low, close = load_ohlc_data('MSFT')

trange = SQA::TAI.trange(high, low, close)

# Compare True Range with simple High-Low range
comparisons = (1...high.length).map do |i|
  simple_range = high[i] - low[i]
  true_range = trange[i]
  difference = true_range - simple_range

  {
    date: i,
    simple: simple_range.round(2),
    true_range: true_range.round(2),
    diff: difference.round(2),
    gap: difference > 0.1  # True Range captures gap
  }
end

# Show cases where True Range differs significantly
gaps = comparisons.select { |c| c[:gap] }
puts "Found #{gaps.size} days with significant gaps"

gaps.last(5).each do |data|
  puts "Day #{data[:date]}: Simple Range=$#{data[:simple]}, " \
       "True Range=$#{data[:true_range]}, Gap=$#{data[:diff]}"
end
```

## Example: Building ATR from True Range

```ruby
high, low, close = load_ohlc_data('NVDA')

# Calculate True Range
trange = SQA::TAI.trange(high, low, close)

# Manually calculate ATR from True Range (for understanding)
period = 14
manual_atr = []

trange.each_with_index do |tr, i|
  if i < period || tr.nil?
    manual_atr << nil
  else
    # Simple moving average of True Range
    avg_tr = trange[(i-period+1)..i].compact.sum / period.0
    manual_atr << avg_tr
  end
end

# Compare with actual ATR
actual_atr = SQA::TAI.atr(high, low, close, period: period)

puts "Manual ATR: #{manual_atr.last.round(4)}"
puts "Actual ATR: #{actual_atr.last.round(4)}"
puts "(Note: Actual ATR uses exponential smoothing, so values may differ slightly)"
```

## Use Cases

### 1. Volatility Measurement
Single period volatility snapshot

### 2. ATR Calculation
Foundation for Average True Range

### 3. Range Analysis
Identify expansion/contraction days

### 4. Gap Detection
Captures overnight price gaps

## True Range Components

```ruby
high, low, close = load_ohlc_data('AAPL')

# Break down True Range calculation
i = -1  # Current bar
h = high[i]
l = low[i]
c_prev = close[i-1]

method1 = h - l  # Current range
method2 = (h - c_prev).abs  # High to previous close
method3 = (l - c_prev).abs  # Low to previous close

puts "Current High - Low: #{method1.round(2)}"
puts "High - Previous Close: #{method2.round(2)}"
puts "Low - Previous Close: #{method3.round(2)}"
puts "True Range (max): #{[method1, method2, method3].max.round(2)}"

# Which method gave the True Range?
if method2 > method1 || method3 > method1
  puts "Gap detected - True Range captures it!"
end
```

## Related Indicators

- [Average True Range (ATR)](atr.md) - Smoothed average of True Range
- [Bollinger Bands](../overlap/bbands.md) - Alternative volatility measure
- [Standard Deviation](../overlap/bbands.md) - Statistical volatility

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Volatility Analysis Example](../../examples/volatility-analysis.md)
