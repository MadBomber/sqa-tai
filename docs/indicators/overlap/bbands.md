# Bollinger Bands (BBANDS)

Bollinger Bands are volatility bands placed above and below a moving average. The bands widen during volatile periods and contract during less volatile periods.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41,
          46.22, 45.64, 46.21, 46.25, 46.08, 46.46,
          46.57, 45.95, 46.50, 46.02]

# Calculate Bollinger Bands
upper, middle, lower = SQA::TAI.bbands(prices, period: 20)

puts "Upper Band: #{upper.last}"
puts "Middle Band: #{middle.last}"
puts "Lower Band: #{lower.last}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values |
| `period` | Integer | No | 5 | Number of periods for MA |
| `nbdev_up` | Float | No | 2.0 | Standard deviations for upper band |
| `nbdev_down` | Float | No | 2.0 | Standard deviations for lower band |
| `ma_type` | Integer | No | 0 | Moving average type (0=SMA) |

## Returns

Returns three arrays:
1. **Upper Band** - Middle band + (nbdev_up × standard deviation)
2. **Middle Band** - Simple moving average
3. **Lower Band** - Middle band - (nbdev_down × standard deviation)

## Interpretation

- **Price at Upper Band**: Potential overbought condition
- **Price at Lower Band**: Potential oversold condition
- **Band Width**: Measures volatility (wide = high volatility)
- **Band Squeeze**: Narrow bands often precede big moves

## Example: Bollinger Band Squeeze

```ruby
prices = load_historical_prices('AAPL')

upper, middle, lower = SQA::TAI.bbands(prices, period: 20, nbdev_up: 2.0, nbdev_down: 2.0)

# Calculate band width
bandwidth = (upper.last - lower.last) / middle.last * 100

# Calculate %B (price position within bands)
percent_b = (prices.last - lower.last) / (upper.last - lower.last) * 100

puts "Bandwidth: #{bandwidth.round(2)}%"
puts "%B: #{percent_b.round(2)}%"

if bandwidth < 10
  puts "Squeeze detected - expect volatility breakout soon!"
end

if percent_b > 100
  puts "Price above upper band - strong momentum or overbought"
elsif percent_b < 0
  puts "Price below lower band - strong momentum or oversold"
end
```

## Example: Mean Reversion Strategy

```ruby
prices = load_historical_prices('TSLA')

upper, middle, lower = SQA::TAI.bbands(prices, period: 20)
current_price = prices.last

# Buy when price touches lower band
if current_price <= lower.last
  puts "Buy Signal: Price at lower Bollinger Band"
  puts "Target: Middle band at #{middle.last.round(2)}"
end

# Sell when price touches upper band
if current_price >= upper.last
  puts "Sell Signal: Price at upper Bollinger Band"
  puts "Target: Middle band at #{middle.last.round(2)}"
end

# Close positions at middle band
if (current_price - middle.last).abs < (upper.last - middle.last) * 0.1
  puts "Near middle band - consider taking profits"
end
```

## Example: Volatility Analysis

```ruby
prices = load_historical_prices('MSFT')

upper, middle, lower = SQA::TAI.bbands(prices, period: 20)

# Historical bandwidth calculation
bandwidths = []
upper.each_with_index do |u, i|
  next unless u && middle[i] && lower[i]
  bandwidths << (u - lower[i]) / middle[i] * 100
end

current_bandwidth = bandwidths.last
avg_bandwidth = bandwidths.compact.sum / bandwidths.compact.size

puts "Current Bandwidth: #{current_bandwidth.round(2)}%"
puts "Average Bandwidth: #{avg_bandwidth.round(2)}%"

if current_bandwidth < avg_bandwidth * 0.7
  puts "Low volatility - squeeze in progress"
elsif current_bandwidth > avg_bandwidth * 1.3
  puts "High volatility - bands expanded"
end
```

## Trading Strategies

### 1. Bollinger Bounce
- Buy at lower band
- Sell at upper band
- Works best in ranging markets

### 2. Bollinger Squeeze
- Narrow bands signal low volatility
- Often followed by significant moves
- Wait for breakout direction

### 3. Walking the Bands
- Strong trends "walk" along a band
- Upper band walk = strong uptrend
- Lower band walk = strong downtrend

### 4. Double Bottom/Top
- W-pattern at lower band = buy
- M-pattern at upper band = sell
- Confirms with divergence

## Common Settings

| Period | Use Case |
|--------|----------|
| 10 | Short-term trading |
| 20 | Standard (most common) |
| 50 | Long-term trends |

| Std Dev | Effect |
|---------|--------|
| 1.5 | Tighter bands, more signals |
| 2.0 | Standard setting |
| 2.5 | Wider bands, fewer signals |

## Related Indicators

- [Simple Moving Average (SMA)](sma.md) - Middle band calculation
- [ATR](../volatility/atr.md) - Alternative volatility measure
- [RSI](../momentum/rsi.md) - Combine for confirmation

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Volatility Analysis Example](../../examples/volatility-analysis.md)
