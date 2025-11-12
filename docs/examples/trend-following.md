# Trend Following Examples

Practical examples of trend-following strategies using SQA::TAI indicators.

## Basic Trend Following

```ruby
require 'sqa/tai'

# Simple moving average crossover
def sma_crossover_strategy(close)
  sma_20 = SQA::TAI.sma(close, period: 20)
  sma_50 = SQA::TAI.sma(close, period: 50)

  # Golden cross (bullish)
  if sma_20.last > sma_50.last && sma_20[-2] <= sma_50[-2]
    return { signal: :buy, reason: "Golden Cross" }
  # Death cross (bearish)
  elsif sma_20.last < sma_50.last && sma_20[-2] >= sma_50[-2]
    return { signal: :sell, reason: "Death Cross" }
  end

  { signal: :hold, reason: "No crossover" }
end
```

## Multi-Indicator Trend System

```ruby
def multi_indicator_trend(open, high, low, close, volume)
  # Trend indicators
  ema_20 = SQA::TAI.ema(close, period: 20)
  ema_50 = SQA::TAI.ema(close, period: 50)

  # Momentum
  macd, signal, hist = SQA::TAI.macd(close)
  adx = SQA::TAI.adx(high, low, close, period: 14)

  # Volume
  obv = SQA::TAI.obv(close, volume)

  # Determine trend
  trend = :neutral
  trend = :bullish if close.last > ema_20.last && ema_20.last > ema_50.last
  trend = :bearish if close.last < ema_20.last && ema_20.last < ema_50.last

  # Confirm with momentum
  momentum_confirmed = false
  if trend == :bullish && macd.last > signal.last && adx.last > 25
    momentum_confirmed = true
  elsif trend == :bearish && macd.last < signal.last && adx.last > 25
    momentum_confirmed = true
  end

  # Volume confirmation
  volume_confirmed = obv.last > obv[-5]

  {
    trend: trend,
    strength: adx.last,
    momentum_confirmed: momentum_confirmed,
    volume_confirmed: volume_confirmed
  }
end
```

## See Also

- [Basics](../basics.md)
- [Indicator Reference](../indicators/index.md)
