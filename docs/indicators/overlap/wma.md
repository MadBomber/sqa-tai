# Weighted Moving Average (WMA)

The Weighted Moving Average (WMA) applies linear weighting to prices, giving more importance to recent data while still considering historical prices.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83,
          45.10, 45.42, 45.84, 46.08, 46.03, 46.41]

# Calculate 10-period WMA
wma = SQA::TAI.wma(prices, period: 10)

puts "Current WMA: #{wma.last}"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array | Yes | - | Array of price values |
| `period` | Integer | No | 30 | Number of periods for calculation |

## Returns

Returns an array of WMA values. The first `period - 1` values will be `nil`.

## Formula

```
WMA = (P1 × n + P2 × (n-1) + ... + Pn × 1) / (n × (n+1) / 2)

where:
  P = Price
  n = Period
```

## Interpretation

- Balances responsiveness and smoothness
- More weight on recent prices (linear)
- Less lag than SMA, more stable than EMA
- Good middle ground between SMA and EMA

## Example: Trend Detection

```ruby
prices = load_historical_prices('AAPL')

wma_20 = SQA::TAI.wma(prices, period: 20)
wma_50 = SQA::TAI.wma(prices, period: 50)

current_price = prices.last

if current_price > wma_20.last && wma_20.last > wma_50.last
  puts "Uptrend: Price above WMA-20, WMA-20 above WMA-50"
elsif current_price < wma_20.last && wma_20.last < wma_50.last
  puts "Downtrend: Price below WMA-20, WMA-20 below WMA-50"
else
  puts "Sideways market: Mixed signals"
end
```

## Example: Comparing Moving Averages

```ruby
prices = load_historical_prices('TSLA')

period = 20
sma = SQA::TAI.sma(prices, period: period)
ema = SQA::TAI.ema(prices, period: period)
wma = SQA::TAI.wma(prices, period: period)

puts "SMA-#{period}: #{sma.last.round(2)}"
puts "EMA-#{period}: #{ema.last.round(2)}"
puts "WMA-#{period}: #{wma.last.round(2)}"
puts "Current Price: #{prices.last.round(2)}"

# WMA typically falls between SMA and EMA
# EMA is most responsive, SMA is most smooth, WMA is in between
```

## Weighting Example

For a 5-period WMA:

```
Most recent price:  weight = 5
1 bar ago:          weight = 4
2 bars ago:         weight = 3
3 bars ago:         weight = 2
4 bars ago:         weight = 1
```

## Use Cases

- **Trend Following**: Smoother than EMA but more responsive than SMA
- **Support/Resistance**: Can act as dynamic support/resistance levels
- **Crossover Systems**: Used in dual moving average strategies
- **Trend Filters**: Confirms trend direction for entry/exit

## Related Indicators

- [Simple Moving Average (SMA)](sma.md) - Equal weighting
- [Exponential Moving Average (EMA)](ema.md) - Exponential weighting
- [Bollinger Bands](bbands.md) - Typically uses SMA

## See Also

- [Back to Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
- [Trend Analysis Example](../../examples/trend-analysis.md)
