# Acceleration Bands (ACCBANDS)

Acceleration Bands are volatility bands similar to Bollinger Bands but use a different calculation method that incorporates price acceleration factors. The bands are calculated using high and low prices with an adjustment factor, making them more responsive to trend acceleration and momentum shifts.

## Usage

```ruby
require 'sqa/tai'

high_prices = [46.08, 46.41, 46.57, 46.50, 46.75, 47.00,
               47.25, 47.50, 47.75, 48.00, 48.25, 48.50,
               48.75, 49.00, 49.25, 49.50, 49.75, 50.00,
               50.25, 50.50, 50.75, 51.00]

low_prices = [44.50, 44.75, 45.00, 45.25, 45.50, 45.75,
              46.00, 46.25, 46.50, 46.75, 47.00, 47.25,
              47.50, 47.75, 48.00, 48.25, 48.50, 48.75,
              49.00, 49.25, 49.50, 49.75]

close_prices = [45.50, 45.75, 46.00, 46.25, 46.50, 46.75,
                47.00, 47.25, 47.50, 47.75, 48.00, 48.25,
                48.50, 48.75, 49.00, 49.25, 49.50, 49.75,
                50.00, 50.25, 50.50, 50.75]

# Calculate Acceleration Bands
upper, middle, lower = SQA::TAI.accbands(high_prices, low_prices, close_prices, period: 20)

puts "Upper Band: #{upper.last.round(2)}"
puts "Middle Band: #{middle.last.round(2)}"
puts "Lower Band: #{lower.last.round(2)}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array | Yes | - | Array of high price values |
| `low` | Array | Yes | - | Array of low price values |
| `close` | Array | Yes | - | Array of close price values |
| `period` | Integer | No | 20 | Number of periods for calculation |

## Returns

Returns three arrays:
1. **Upper Band** - High prices adjusted by acceleration factor
2. **Middle Band** - Simple moving average of close prices
3. **Lower Band** - Low prices adjusted by acceleration factor

The first `period - 1` values will be `nil`.

## Interpretation

| Signal | Interpretation |
|--------|----------------|
| Price touches upper band | Potential acceleration in uptrend, breakout signal |
| Price touches lower band | Potential acceleration in downtrend, breakdown signal |
| Price within bands | Normal price action, no acceleration |
| Band expansion | Increasing volatility and momentum |
| Band contraction | Decreasing volatility, potential consolidation |

## Example: Breakout Detection

```ruby
high = load_historical_data('AAPL', field: :high)
low = load_historical_data('AAPL', field: :low)
close = load_historical_data('AAPL', field: :close)

upper, middle, lower = SQA::TAI.accbands(high, low, close, period: 20)

current_close = close.last
current_high = high.last
current_low = low.last

# Detect breakouts
if current_close > upper.last
  puts "Bullish Breakout: Price accelerating above upper band"
  puts "Entry: #{current_close.round(2)}"
  puts "Stop: #{middle.last.round(2)}"
elsif current_close < lower.last
  puts "Bearish Breakdown: Price accelerating below lower band"
  puts "Entry: #{current_close.round(2)}"
  puts "Stop: #{middle.last.round(2)}"
end

# Calculate band width for volatility assessment
bandwidth = ((upper.last - lower.last) / middle.last * 100).round(2)
puts "Current Bandwidth: #{bandwidth}%"
```

## Example: Trend Acceleration Strategy

```ruby
high = load_historical_data('TSLA', field: :high)
low = load_historical_data('TSLA', field: :low)
close = load_historical_data('TSLA', field: :close)

upper, middle, lower = SQA::TAI.accbands(high, low, close, period: 20)

# Look at recent price action
recent_closes = close[-5..-1]
recent_uppers = upper[-5..-1].compact
recent_lowers = lower[-5..-1].compact

# Count touches of bands
upper_touches = recent_closes.zip(recent_uppers).count { |c, u| c >= u }
lower_touches = recent_closes.zip(recent_lowers).count { |c, l| c <= l }

if upper_touches >= 3
  puts "Strong Uptrend: Multiple upper band touches"
  puts "Trend is accelerating - consider trailing stop"
elsif lower_touches >= 3
  puts "Strong Downtrend: Multiple lower band touches"
  puts "Downward acceleration - avoid catching falling knife"
end

# Check for mean reversion opportunity
if close.last < lower.last && close[-2] > lower[-2]
  puts "Potential Mean Reversion: First touch of lower band"
  puts "Target: Middle band at #{middle.last.round(2)}"
end
```

## Example: Comparing with Bollinger Bands

```ruby
high = load_historical_data('MSFT', field: :high)
low = load_historical_data('MSFT', field: :low)
close = load_historical_data('MSFT', field: :close)

# Calculate both band types
acc_upper, acc_middle, acc_lower = SQA::TAI.accbands(high, low, close, period: 20)
bb_upper, bb_middle, bb_lower = SQA::TAI.bbands(close, period: 20)

# Compare band widths
acc_width = ((acc_upper.last - acc_lower.last) / acc_middle.last * 100).round(2)
bb_width = ((bb_upper.last - bb_lower.last) / bb_middle.last * 100).round(2)

puts "Acceleration Bands Width: #{acc_width}%"
puts "Bollinger Bands Width: #{bb_width}%"

# Acceleration Bands typically show earlier expansion
if acc_width > bb_width * 1.1
  puts "ACCBANDS showing early volatility expansion"
  puts "Momentum may be building"
elsif bb_width > acc_width * 1.1
  puts "BBANDS wider - statistical volatility higher"
  puts "Price action may be more erratic"
end

# Check for convergence/divergence signals
if close.last > acc_upper.last && close.last > bb_upper.last
  puts "Strong Breakout: Above both band types"
  puts "High conviction signal"
elsif close.last > acc_upper.last && close.last < bb_upper.last
  puts "Early Momentum: ACCBANDS breakout first"
  puts "Watch for BBANDS confirmation"
end
```

## Trading Strategies

### 1. Acceleration Breakout
- Enter when price closes above upper band
- Confirms momentum acceleration
- Set stop at middle band
- Target previous swing highs

### 2. Band Walk Strategy
- Price walking along upper band = strong uptrend
- Price walking along lower band = strong downtrend
- Stay with trend until band crosses back

### 3. Squeeze and Expansion
- Narrow bands indicate low volatility
- Wait for expansion and breakout
- Direction of expansion signals trend

### 4. False Breakout Filter
- Use with volume indicators
- Require multiple period closes beyond bands
- Avoid whipsaws in ranging markets

## Common Settings

| Period | Use Case |
|--------|----------|
| 10 | Short-term trading, day trading |
| 20 | Standard setting (most common) |
| 50 | Long-term trends, position trading |
| 100 | Major trend identification |

## Differences from Bollinger Bands

| Feature | Acceleration Bands | Bollinger Bands |
|---------|-------------------|-----------------|
| Calculation | Uses high/low with acceleration factor | Uses standard deviation |
| Sensitivity | More responsive to momentum | More responsive to volatility |
| Best Use | Trend acceleration, breakouts | Volatility, mean reversion |
| Band Width | Based on price range | Based on statistical deviation |

## Related Indicators

- [Bollinger Bands (BBANDS)](bbands.md) - Similar volatility bands
- [Keltner Channels](kama.md) - ATR-based bands
- [ATR](../volatility/atr.md) - Volatility measurement
- [ADX](../momentum/adx.md) - Trend strength confirmation

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Volatility Analysis Example](../../examples/volatility-analysis.md)
