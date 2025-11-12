# Rate of Change (ROC)

The Rate of Change (ROC) is a momentum oscillator that measures the percentage change in price between the current price and the price n periods ago.

## Formula

ROC = ((Price - Price n periods ago) / Price n periods ago) * 100

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prices` | Array<Float> | Yes | - | Array of price values |
| `period` | Integer | No | 10 | Lookback period |

## Returns

Returns an array of ROC values as percentages.

## Usage

```ruby
require 'sqa/tai'

prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42, 45.84, 46.08, 46.03, 46.41]

roc = SQA::TAI.roc(prices, period: 10)

puts "Current ROC: #{roc.last.round(2)}%"
```

## Interpretation

- **Positive ROC**: Price is higher than n periods ago (upward momentum)
- **Negative ROC**: Price is lower than n periods ago (downward momentum)
- **ROC crosses above zero**: Bullish signal
- **ROC crosses below zero**: Bearish signal
- **Extreme ROC values**: May indicate overbought/oversold conditions

## Example: ROC Divergence

```ruby
prices = load_historical_prices('AAPL')
roc = SQA::TAI.roc(prices, period: 12)

# Check for divergence
if prices.last > prices[-10] && roc.last < roc[-10]
  puts "BEARISH DIVERGENCE: Price higher but ROC lower"
elsif prices.last < prices[-10] && roc.last > roc[-10]
  puts "BULLISH DIVERGENCE: Price lower but ROC higher"
end
```

## Common Settings

| Period | Use Case |
|--------|----------|
| 9 | Short-term momentum |
| 12-14 | Standard trading |
| 20-25 | Longer-term momentum |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Related Indicators

- [ROCP](rocp.md) - Rate of Change Percentage
- [ROCR](rocr.md) - Rate of Change Ratio
- [ROCR100](rocr100.md) - Rate of Change Ratio 100 Scale
- [MOM](mom.md) - Momentum

## See Also

- [Back to Indicators](../index.md)
- [Momentum Indicators Overview](../index.md)
