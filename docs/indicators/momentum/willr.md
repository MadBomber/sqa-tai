# Williams %R (WILLR)

Williams %R is a momentum indicator that measures overbought and oversold levels. It compares the closing price to the high-low range over a specific period, providing values between 0 and -100.

## Formula

%R = (Highest High - Close) / (Highest High - Lowest Low) * -100

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `high` | Array<Float> | Yes | - | Array of high prices |
| `low` | Array<Float> | Yes | - | Array of low prices |
| `close` | Array<Float> | Yes | - | Array of close prices |
| `period` | Integer | No | 14 | Lookback period |

## Returns

Returns an array of Williams %R values ranging from 0 to -100.

## Usage

```ruby
require 'sqa/tai'

high =  [48.70, 48.72, 48.90, 48.87, 48.82, 49.05, 49.20, 49.35, 49.92, 50.19, 50.12, 50.10, 50.00, 49.75, 49.80]
low =   [47.79, 48.14, 48.39, 48.37, 48.24, 48.64, 48.94, 49.03, 49.50, 49.87, 49.20, 49.00, 48.90, 49.00, 49.10]
close = [48.20, 48.61, 48.75, 48.63, 48.74, 49.03, 49.07, 49.32, 49.91, 50.13, 49.53, 49.50, 49.25, 49.20, 49.45]

willr = SQA::TAI.willr(high, low, close, period: 14)

puts "Current Williams %R: #{willr.last.round(2)}"
```

## Interpretation

| Williams %R | Interpretation |
|-------------|----------------|
| 0 to -20 | Overbought |
| -20 to -80 | Normal trading range |
| -80 to -100 | Oversold |

**Note**: Array elements should be ordered from oldest to newest (chronological order)

## Example: Basic Trading Signals

```ruby
high, low, close = load_historical_ohlc('AAPL')
willr = SQA::TAI.willr(high, low, close, period: 14)

current = willr.last

if current > -20
  puts "OVERBOUGHT: Williams %R at #{current.round(2)}"
elsif current < -80
  puts "OVERSOLD: Williams %R at #{current.round(2)}"
else
  puts "NEUTRAL: Williams %R at #{current.round(2)}"
end
```

## Common Settings

| Period | Use Case |
|--------|----------|
| 10 | Short-term trading |
| 14 | Standard (most common) |
| 20 | Longer-term analysis |

## Related Indicators

- [STOCH](stoch.md) - Stochastic Oscillator
- [RSI](rsi.md) - Relative Strength Index
- [CCI](cci.md) - Commodity Channel Index

## See Also

- [Back to Indicators](../index.md)
- [Momentum Indicators Overview](../index.md)
