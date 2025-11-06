# Simple Moving Average (SMA)

The Simple Moving Average (SMA) is the most basic and widely used moving average, calculated by summing up prices over a specified period and dividing by that period.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41]

# Calculate 5-period SMA
sma = SQA::TAI.sma(prices, period: 5)

puts "Current SMA: #{sma.last}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values |
| `period` | Integer | No | 30 | Number of periods for calculation |

## Returns

Returns an array of SMA values. The first `period - 1` values will be `nil`.

## Interpretation

- **Uptrend**: Price above SMA indicates bullish trend
- **Downtrend**: Price below SMA indicates bearish trend
- **Support/Resistance**: SMA often acts as dynamic support/resistance
- **Crossovers**: Price crossing SMA signals potential trend changes

## Example: Golden Cross Detection

```ruby
prices = load_historical_prices('AAPL')

# Calculate two SMAs
sma_50 = SQA::TAI.sma(prices, period: 50)
sma_200 = SQA::TAI.sma(prices, period: 200)

# Check for golden cross (bullish signal)
if sma_50[-2] < sma_200[-2] && sma_50[-1] > sma_200[-1]
  puts "Golden Cross - Strong buy signal!"
end

# Check for death cross (bearish signal)
if sma_50[-2] > sma_200[-2] && sma_50[-1] < sma_200[-1]
  puts "Death Cross - Strong sell signal!"
end
```

## Example: Multiple Timeframe Analysis

```ruby
prices = load_historical_prices('TSLA')

# Calculate multiple SMAs
sma_20 = SQA::TAI.sma(prices, period: 20)
sma_50 = SQA::TAI.sma(prices, period: 50)
sma_100 = SQA::TAI.sma(prices, period: 100)
sma_200 = SQA::TAI.sma(prices, period: 200)

current_price = prices.last

# Check trend alignment
if current_price > sma_20.last &&
   sma_20.last > sma_50.last &&
   sma_50.last > sma_100.last &&
   sma_100.last > sma_200.last
  puts "Strong uptrend - all moving averages aligned!"
end
```

## Related Indicators

- [Exponential Moving Average (EMA)](ema.md) - Gives more weight to recent prices
- [Weighted Moving Average (WMA)](wma.md) - Linear weighting of prices
- [Bollinger Bands](bbands.md) - Uses SMA as middle band

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Trend Analysis Example](../../examples/trend-analysis.md)
