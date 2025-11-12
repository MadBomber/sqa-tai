# Overlap Studies

Overlap studies are indicators that are plotted directly on the price chart, "overlaying" the price action. These include moving averages, bands, and envelopes that help identify trends and support/resistance levels.

## Available Overlap Indicators

### Moving Averages

- [Simple Moving Average (SMA)](sma.md) - Arithmetic average of prices
- [Exponential Moving Average (EMA)](ema.md) - Weighted average favoring recent prices
- [Weighted Moving Average (WMA)](wma.md) - Linearly weighted average
- [Double Exponential Moving Average (DEMA)](dema.md) - Reduced lag EMA
- [Triple Exponential Moving Average (TEMA)](tema.md) - Further reduced lag
- [Triangular Moving Average (TRIMA)](trima.md) - Smoothed double average
- [Kaufman Adaptive Moving Average (KAMA)](kama.md) - Adjusts to volatility
- [T3 Moving Average (T3)](t3.md) - Smooth moving average

### Bands and Envelopes

- [Bollinger Bands (BBANDS)](bbands.md) - Volatility-based bands
- [Adaptive Bollinger Bands (ACCBANDS)](accbands.md) - Dynamic bands

### Other Overlays

- [Moving Average (MA)](ma.md) - Configurable MA type
- [VWAP](vwap.md) - Volume-weighted average price (reference)

## Common Usage

```ruby
require 'sqa/tai'

close = [45.0, 46.0, 45.5, 47.0, 46.5, 48.0, 47.5, 49.0, 48.5, 50.0]

# Simple Moving Average
sma = SQA::TAI.sma(close, period: 20)

# Exponential Moving Average
ema = SQA::TAI.ema(close, period: 20)

# Bollinger Bands
upper, middle, lower = SQA::TAI.bbands(close, period: 20)
```

## See Also

- [All Indicators](../index.md)
- [Basic Usage](../../getting-started/basic-usage.md)
